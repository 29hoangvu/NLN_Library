<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<html>
<head>
    <title>Đăng ký</title>
</head>
<body>
    <h2>Đăng ký tài khoản</h2>
    <form action="RegisterServlet" method="post">
        Tên đăng nhập: <input type="text" name="username" required><br>
        Mật khẩu: <input type="password" name="password" required><br>
        <input type="submit" value="Đăng ký">
    </form>
</body>
</html>
