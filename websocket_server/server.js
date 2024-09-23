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

    if (action === "get_group_chats") {
      db.query(
        `SELECT a.activity_id, a.activity_name, c.messages AS last_message, u.user_photo 
        FROM activity a
        JOIN chat c ON a.activity_id = c.activity_id
        JOIN user_information u ON u.user_id = c.user_id
        WHERE c.user_id = ? 
        GROUP BY a.activity_id
        ORDER BY c.timestamp DESC`,
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

    // กรณีที่ client ต้องการดึงข้อความของ activity นั้นๆ
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
            // ส่งข้อมูลในรูปแบบ JSON ที่สามารถจัดการได้ง่ายขึ้น
            const messages = rows.map((row) => ({
              user_id: row.user_id,
              user_name: row.user_name,
              user_photo: row.user_photo,
              message: row.message,
              timestamp: row.timestamp,
            }));

            ws.send(
              JSON.stringify({
                action: "messages",
                messages: messages, // ส่งข้อมูลทั้งหมดเป็น array ของ messages
              })
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
