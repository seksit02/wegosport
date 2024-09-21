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

    // กรณีที่ client ต้องการดึงข้อความของ activity นั้นๆ
    if (action === "get_messages") {
      // ในโค้ดเซิร์ฟเวอร์ส่วนการดึงข้อความ
      db.query(
        "SELECT * FROM messages WHERE activity_id = ? ORDER BY timestamp ASC LIMIT 50",
        [activityId], // ส่ง activity_id เพื่อกรองข้อมูล
        (err, rows) => {
          if (err) {
            console.log("Error retrieving messages:", err);
            ws.send("Error retrieving messages");
          } else {
            rows.forEach((row) => {
              ws.send(`${row.user_id}: ${row.message}`);
            });
          }
        }
      );
    }

    // กรณีที่ client ส่งข้อความใหม่
    if (action === "send_message") {
      let msgContent = parsedMessage.message;

      // บันทึกข้อความลงในฐานข้อมูล
      const query =
        "INSERT INTO messages (user_id, user_name, user_photo, activity_id, message, timestamp, status) VALUES (?, ?, ?, ?, ?, NOW(), 'sent')";
      db.query(
        query,
        [userId, userName, userPhoto, activityId, msgContent],
        (err, res) => {
          if (err) {
            console.log("Error saving message to DB:", err);
            ws.send("Error saving message");
          } else {
            console.log("Message saved to DB for activityId:", activityId);

            // Broadcast ข้อความให้กับทุก client ที่เชื่อมต่ออยู่
            clients.forEach((client) => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(`${userId}: ${msgContent}`);
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
