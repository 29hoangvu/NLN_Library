<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<html>
<head>
    <title>Đăng nhập</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .login-container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 320px;
        }

        .header {
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
        }

        .btn-back {
            background-color: #ccc;
            color: black;
            padding: 8px 12px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 10px;
        }

        .btn-back:hover {
            background-color: #bbb;
        }

        h2 {
            margin: 0;
            font-size: 20px;
        }

        form {
            display: flex;
            flex-direction: column;
        }

        input {
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
        }

        button {
            background-color: #28a745;
            color: white;
            padding: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        button:hover {
            background-color: #218838;
        }

        p {
            margin-top: 10px;
        }

        a {
            color: #007bff;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="header">
            <a href="index.jsp" class="btn-back">
                <i class="fa fa-arrow-left"></i>
            </a>
            <h2>Đăng nhập</h2>
        </div>
        
        <form action="LoginServlet" method="post">
            <label for="username">Tên đăng nhập</label>
            <input type="text" id="username" name="username" required>

            <label for="password">Mật khẩu</label>
            <input type="password" id="password" name="password" required>

            <button type="submit">Đăng nhập</button>
            <p>Chưa có tài khoản? <a href="register.jsp">Đăng ký ngay</a></p>
        </form>
    </div>
</body>
</html>
