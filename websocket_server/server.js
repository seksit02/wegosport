const WebSocket = require("ws");
const mysql = require("mysql");

// สร้างการเชื่อมต่อกับฐานข้อมูล MySQL
const db = mysql.createConnection({
  host: "localhost", // ตั้งค่าตามเซิร์ฟเวอร์ของคุณ
  user: "root", // ชื่อผู้ใช้ฐานข้อมูล
  password: "", // รหัสผ่าน
  database: "wegosport", // ชื่อฐานข้อมูล
});

db.connect((err) => {
  if (err) throw err;
  console.log("Connected to MySQL database");
});

const server = new WebSocket.Server({ port: 8080 });

server.on("connection", (ws) => {
  console.log("Client connected");

  // ดึงข้อความเก่าจากฐานข้อมูล
  db.query(
    "SELECT * FROM messages ORDER BY timestamp DESC LIMIT 50",
    (err, rows) => {
      if (err) {
        console.log("Error retrieving messages:", err);
        ws.send("Error retrieving messages");
      } else {
        // ส่งข้อความเก่ากลับไปยัง client
        rows.forEach((row) => {
          ws.send(`${row.user_id}: ${row.message}`);
        });
      }
    }
  );

  // ส่งข้อความต้อนรับไปยัง client
  ws.send("Welcome to the WebSocket server!");

  // รับข้อความจาก client และบันทึกลงฐานข้อมูล
  ws.on("message", (message) => {
    console.log(`ได้รับ: ${message}`);

    // แปลงข้อความ JSON เป็นอ็อบเจกต์
    let parsedMessage = JSON.parse(message);

    let userId = parsedMessage.user_id;
    let msgContent = parsedMessage.message;

    // ดึง member_id จากตาราง member_in_activity ตาม user_id
    db.query(
      "SELECT member_id FROM member_in_activity WHERE user_id = ?",
      [userId],
      (err, result) => {
        if (err || result.length === 0) {
          console.log(
            "Error retrieving member_id or member_id not found:",
            err
          );
          ws.send("Error retrieving member_id");
        } else {
          let memberId = result[0].member_id;

          // เพิ่มข้อมูลลงในฐานข้อมูล
          const query =
            "INSERT INTO messages (user_id, member_id, message, timestamp, status) VALUES (?, ?, ?, NOW(), 'sent')";
          db.query(query, [userId, memberId, msgContent], (err, result) => {
            if (err) {
              console.log("Error saving message to DB:", err);
              ws.send("Error saving message");
            } else {
              console.log("Message saved to DB");
              ws.send(`เซิร์ฟเวอร์ได้รับแล้ว: ${msgContent}`);
            }
          });
        }
      }
    );
  });

  ws.on("close", () => {
    console.log("Client disconnected");
  });
});

console.log("WebSocket server is running on ws://localhost:8080");
