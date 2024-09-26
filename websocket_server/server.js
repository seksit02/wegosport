const WebSocket = require("ws"); // นำเข้า WebSocket library เพื่อใช้สร้าง WebSocket server
const mysql = require("mysql"); // นำเข้า MySQL library เพื่อเชื่อมต่อฐานข้อมูล MySQL

// สร้างการเชื่อมต่อกับฐานข้อมูล MySQL
const db = mysql.createConnection({
  host: "localhost", // กำหนดโฮสต์ของฐานข้อมูล MySQL
  user: "root", // ชื่อผู้ใช้ของ MySQL
  password: "", // รหัสผ่านของ MySQL (ในที่นี้ไม่ได้ตั้งรหัสผ่าน)
  database: "wegosport", // ชื่อฐานข้อมูลที่ใช้
});

// เริ่มการเชื่อมต่อฐานข้อมูล
db.connect((err) => {
  if (err) throw err; // ถ้าเกิดข้อผิดพลาดในการเชื่อมต่อ ให้แสดงข้อผิดพลาด
  console.log("Connected to MySQL database"); // แจ้งว่าการเชื่อมต่อสำเร็จ
});

// สร้าง WebSocket server ที่รันบนพอร์ต 8080
const server = new WebSocket.Server({ port: 8080 });

// สร้าง Set เพื่อเก็บการเชื่อมต่อของ clients ที่เชื่อมต่อเข้ามา
const clients = new Set();

server.on("connection", (ws) => {
  // เมื่อ client เชื่อมต่อเข้ามา
  console.log("Client connected"); // แจ้งว่ามี client เชื่อมต่อเข้ามา
  clients.add(ws); // เพิ่ม client ที่เชื่อมต่อใหม่ลงใน Set

  ws.on("message", (message) => {
    // เมื่อได้รับข้อความจาก client
    let parsedMessage = JSON.parse(message); // แปลงข้อความที่ได้รับจาก client จาก JSON เป็น object
    let action = parsedMessage.action; // แยก action ออกมาเพื่อระบุประเภทของคำขอ
    let activityId = parsedMessage.activity_id; // รับ activity_id ที่ถูกส่งมาจาก client
    let userId = parsedMessage.user_id; // รับ user_id ของผู้ใช้
    let userName = parsedMessage.user_name; // รับชื่อของผู้ใช้
    let userPhoto = parsedMessage.user_photo; // รับรูปภาพของผู้ใช้

    // ถ้า action คือ 'get_group_chats' จะเป็นการดึงรายการแชทของผู้ใช้
    if (action === "get_group_chats") {
      db.query(
        `SELECT a.activity_id, a.activity_name, 
            (SELECT m.message FROM messages m WHERE m.activity_id = a.activity_id ORDER BY m.timestamp DESC LIMIT 1) AS last_message, 
            (SELECT u.user_photo FROM user_information u JOIN messages m ON u.user_id = m.user_id WHERE m.activity_id = a.activity_id ORDER BY m.timestamp DESC LIMIT 1) AS user_photo 
     FROM activity a
     JOIN member_in_activity mia ON mia.activity_id = a.activity_id
     WHERE mia.user_id = ?
     GROUP BY a.activity_id
     ORDER BY (SELECT m.timestamp FROM messages m WHERE m.activity_id = a.activity_id ORDER BY m.timestamp DESC LIMIT 1) DESC`,
        [userId], // ส่ง user_id เพื่อดึงรายการแชทที่ผู้ใช้เข้าร่วม
        (err, rows) => {
          // ทำการประมวลผลผลลัพธ์จาก query
          if (err) {
            console.log("Error retrieving group chats:", err); // แสดงข้อผิดพลาดถ้า query ผิดพลาด
            ws.send(
              JSON.stringify({
                action: "error",
                message: "Error retrieving group chats", // ส่งข้อความแสดงข้อผิดพลาดกลับไปที่ client
              })
            );
          } else {
            const chats = rows.map((row) => ({
              activity_id: row.activity_id, // กำหนด activity_id ของแต่ละแชท
              activity_name: row.activity_name, // ชื่อกิจกรรม
              last_message: row.last_message, // ข้อความล่าสุดในแชทนั้น
              user_photo: row.user_photo, // รูปของผู้ใช้คนสุดท้ายที่ส่งข้อความ
            }));

            ws.send(JSON.stringify({ action: "group_chats", chats })); // ส่งรายการแชทกลับไปที่ client
          }
        }
      );
    }

    // ถ้า action คือ 'get_messages' จะเป็นการดึงข้อความของกิจกรรมที่กำหนด
    if (action === "get_messages") {
      db.query(
        "SELECT * FROM messages WHERE activity_id = ? ORDER BY timestamp ASC LIMIT 50",
        [activityId], // ส่ง activity_id เพื่อกรองข้อความของกิจกรรมที่กำหนด
        (err, rows) => {
          if (err) {
            console.log("Error retrieving messages:", err); // แสดงข้อผิดพลาดถ้า query ผิดพลาด
            ws.send(
              JSON.stringify({
                action: "error",
                message: "Error retrieving messages", // ส่งข้อความแสดงข้อผิดพลาดกลับไปที่ client
              })
            );
          } else {
            const messages = rows.map((row) => ({
              user_id: row.user_id, // user_id ของผู้ที่ส่งข้อความ
              user_name: row.user_name, // ชื่อผู้ที่ส่งข้อความ
              user_photo: row.user_photo, // รูปของผู้ที่ส่งข้อความ
              message: row.message, // เนื้อหาข้อความ
              timestamp: row.timestamp, // เวลาที่ส่งข้อความ
              status: row.status, // สถานะของข้อความ เช่น 'read' หรือ 'sent'
            }));

            ws.send(
              JSON.stringify({
                action: "messages",
                messages: messages, // ส่งรายการข้อความกลับไปที่ client
              })
            );

            // อัปเดตสถานะเป็น 'read' เมื่อมีการดึงข้อความ
            db.query(
              "UPDATE messages SET status = 'read' WHERE activity_id = ?",
              [activityId]
            );
          }
        }
      );
    }

    // ถ้า action คือ 'send_message' จะเป็นการส่งข้อความใหม่
    if (action === "send_message") {
      let msgContent = parsedMessage.message; // ดึงข้อความจาก client

      // แยกชื่อไฟล์รูปภาพออกจาก URL เพื่อบันทึกเฉพาะชื่อไฟล์ลงในฐานข้อมูล
      let photoName = userPhoto.split("/").pop();

      // บันทึกข้อความลงในฐานข้อมูล
      const query =
        "INSERT INTO messages (user_id, user_name, user_photo, activity_id, message, timestamp, status) VALUES (?, ?, ?, ?, ?, NOW(), 'sent')";
      db.query(
        query,
        [userId, userName, photoName, activityId, msgContent], // ส่งค่าที่จำเป็นสำหรับการบันทึกข้อความ
        (err, res) => {
          if (err) {
            console.log("Error saving message to DB:", err); // แสดงข้อผิดพลาดถ้า query ผิดพลาด
            ws.send("Error saving message"); // ส่งข้อความแสดงข้อผิดพลาดกลับไปที่ client
          } else {
            console.log("Message saved to DB for activityId:", activityId); // แสดงว่าข้อความถูกบันทึกแล้ว

            // ส่งข้อความใหม่ให้กับทุก client ที่เชื่อมต่ออยู่
            const newMessage = {
              user_id: userId,
              user_name: userName,
              user_photo: userPhoto,
              message: msgContent,
              activity_id: activityId,
            };

            clients.forEach((client) => {
              // กระจายข้อความใหม่ไปยังทุก client
              if (client.readyState === WebSocket.OPEN) {
                // ตรวจสอบว่า client ยังเชื่อมต่ออยู่หรือไม่
                client.send(
                  JSON.stringify({
                    action: "new_message",
                    message: newMessage, // ส่งข้อความใหม่ไปที่ client
                  })
                );
              }
            });
          }
        }
      );
    }
  });

  ws.on("close", () => {
    // เมื่อ client ตัดการเชื่อมต่อ
    console.log("Client disconnected"); // แสดงข้อความว่า client ได้ตัดการเชื่อมต่อแล้ว
    clients.delete(ws); // ลบ client ออกจาก Set
  });
});

// แสดงข้อความว่า WebSocket server กำลังทำงาน
console.log("WebSocket server is running on ws://localhost:8080");
