const WebSocket = require("ws");
const mysql = require("mysql");

// สร้างการเชื่อมต่อกับฐานข้อมูล MySQL
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "wegosport",
});

db.connect((err) => {
  if (err) throw err;
  console.log("Connected to MySQL database");
});

const server = new WebSocket.Server({ port: 8080 });

// เก็บ connection ของ clients ที่เชื่อมต่อทั้งหมด
const clients = new Set();

server.on("connection", (ws) => {
  console.log("Client connected");
  clients.add(ws); // เพิ่ม client ที่เชื่อมต่อใหม่ลงใน set

  ws.on("message", (message) => {
    let parsedMessage = JSON.parse(message);
    let action = parsedMessage.action;
    let activityId = parsedMessage.activity_id;
    let userId = parsedMessage.user_id;
    let userName = parsedMessage.user_name;
    let userPhoto = parsedMessage.user_photo;

    // ดึงรายการแชทของผู้ใช้
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
        [userId], // ส่ง user_id เพื่อดึงรายการแชทของผู้ใช้
        (err, rows) => {
          if (err) {
            console.log("Error retrieving group chats:", err);
            ws.send(
              JSON.stringify({
                action: "error",
                message: "Error retrieving group chats",
              })
            );
          } else {
            const chats = rows.map((row) => ({
              activity_id: row.activity_id,
              activity_name: row.activity_name,
              last_message: row.last_message,
              user_photo: row.user_photo,
            }));

            ws.send(JSON.stringify({ action: "group_chats", chats }));
          }
        }
      );
    }

    // ดึงข้อความของ activity นั้นๆ
    if (action === "get_messages") {
      db.query(
        "SELECT * FROM messages WHERE activity_id = ? ORDER BY timestamp ASC LIMIT 50",
        [activityId], // ส่ง activity_id เพื่อกรองข้อมูล
        (err, rows) => {
          if (err) {
            console.log("Error retrieving messages:", err);
            ws.send(
              JSON.stringify({
                action: "error",
                message: "Error retrieving messages",
              })
            );
          } else {
            const messages = rows.map((row) => ({
              user_id: row.user_id,
              user_name: row.user_name,
              user_photo: row.user_photo,
              message: row.message,
              timestamp: row.timestamp, // ส่งข้อมูล timestamp
              status: row.status, // ส่งสถานะของข้อความด้วย
            }));

            ws.send(
              JSON.stringify({
                action: "messages",
                messages: messages,
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

    // กรณีที่ client ส่งข้อความใหม่
    if (action === "send_message") {
      let msgContent = parsedMessage.message;

      // แยกชื่อไฟล์รูปภาพออกจาก URL
      let photoName = userPhoto.split("/").pop();

      // บันทึกข้อความลงในฐานข้อมูล
      const query =
        "INSERT INTO messages (user_id, user_name, user_photo, activity_id, message, timestamp, status) VALUES (?, ?, ?, ?, ?, NOW(), 'sent')";
      db.query(
        query,
        [userId, userName, photoName, activityId, msgContent], // ใช้ photoName แทน userPhoto
        (err, res) => {
          if (err) {
            console.log("Error saving message to DB:", err);
            ws.send("Error saving message");
          } else {
            console.log("Message saved to DB for activityId:", activityId);

            // Broadcast ข้อความใหม่ให้กับทุก client ที่เชื่อมต่ออยู่ในรูปแบบ JSON
            const newMessage = {
              user_id: userId,
              user_name: userName,
              user_photo: userPhoto,
              message: msgContent,
              activity_id: activityId,
            };

            clients.forEach((client) => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(
                  JSON.stringify({
                    action: "new_message",
                    message: newMessage,
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
    console.log("Client disconnected");
    clients.delete(ws); // ลบ client ที่ตัดการเชื่อมต่อ
  });
});

console.log("WebSocket server is running on ws://localhost:8080");
