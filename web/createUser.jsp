<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Thêm Người Dùng - Admin</title>
    <link rel="stylesheet" href="./CSS/admin.css">
    <script>
        // Hiển thị thông báo từ URL nếu có
        window.onload = function () {
            const urlParams = new URLSearchParams(window.location.search);
            const message = urlParams.get('message');
            if (message) {
                alert(decodeURIComponent(message));
            }
        };
    </script>
</head>
<body>
    <div class="navbar">
        <h1>Quản lý sách - Admin</h1>
    </div>
    <div class="sidebar">
        <h2>Menu</h2>
        <ul>
            <li><a href="bookList.jsp">Dashboard</a></li>
            <li><a href="admin.jsp">Thêm sách</a></li>
            <li><a href="addBookItem.jsp">Vị trí sách</a></li>
            <li><a href="createUser.jsp">Tạo tài khoản</a></li>
        </ul>
    </div>
    <div class="content">
        <h2>👤 Thêm Người Dùng Mới</h2>
        <form action="AddUserServlet" method="post">
            <label for="username">Tên người dùng:</label>
            <input type="text" id="username" name="username" placeholder="Nhập tên đăng nhập" required>

            <label for="password">Mật khẩu:</label>
            <input type="password" id="password" name="password" placeholder="Nhập mật khẩu" required>

            <label for="roleID">Chọn vai trò:</label>
            <select id="roleID" name="roleID" required>
                <option value="1">Admin</option>
                <option value="2">Librarian</option>
                <option value="3">Member</option>
            </select>

            <button type="submit">Thêm Người Dùng</button>
        </form>
    </div>
</body>
</html>
