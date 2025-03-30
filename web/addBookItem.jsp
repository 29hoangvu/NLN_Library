<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, Servlet.DBConnection" %>
<%@ page import="Data.Users" %>
<%
    Users user = (Users) session.getAttribute("user");

    // Kiểm tra nếu chưa đăng nhập hoặc không có quyền truy cập
    if (user == null || (user.getRoleID() != 1 && user.getRoleID() != 2)) {
        response.sendRedirect("index.jsp"); // Chuyển về trang chính nếu không có quyền
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Thêm Vị Trí Sách</title>
    <link rel="stylesheet" href="./CSS/admin1.css">
    <link rel="stylesheet" href="./CSS/ad_menu.css">
    <script src="./JS/admin.js"></script> 
    <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />
    <script>
        // Hàm để hiển thị thông báo alert
        function showAlert(message, status) {
            if (status === 'success') {
                alert(message);  // Hiển thị thông báo thành công
            } else if (status === 'error') {
                alert(message);  // Hiển thị thông báo lỗi
            }
        }
    </script>
</head>
<body>
    <div class="navbar">
        <h1>Quản lý sách - Admin</h1>
    </div>
    <div class="sidebar">
        <h2>Menu</h2>
        <ul>
            <li><a href="adminDashboard.jsp">Dashboard</a></li>
            <li><a href="admin.jsp">Thêm sách</a></li>
            <li><a href="addBookItem.jsp">Vị trí sách</a></li>
            <% if (user.getRoleID() == 1) { %>
                <li><a href="createUser.jsp">Quản lý người dùng</a></li>
            <% } %>
            <li><a href="adminBorrowedBooks.jsp">Quản lý mượn trả sách</a></li>
        </ul>
        <div class="user-menu" onclick="toggleUserMenu()">
            <span><%= user.getUsername() %></span>
            <span id="arrowIcon" class="arrow">▼</span>
        </div>
        <div id="userDropup" class="user-dropup">
            <a href="#">Thông tin cá nhân</a>
            <a href="#">Cài đặt</a>
            <a href="LogOutServlet">Đăng xuất</a>
        </div>
    </div>
    <div class="content">
        <h2>Thêm Vị Trí Sách</h2>
        <!-- Kiểm tra thông báo từ URL -->
        <%
            String message = request.getParameter("message");
            String status = request.getParameter("status");
            if (message != null && status != null) {
        %>
            <script>
                window.onload = function() {
                    showAlert("<%= message %>", "<%= status %>");
                };
            </script>
        <%
            }
        %>

        <form class="form" action="BookItemServlet" method="post">
            ISBN hoặc Tên sách
            <input name="bookId" list="bookList" placeholder="Nhập ISBN hoặc tên sách" required>
            <datalist id="bookList">
                <%
                    try (Connection conn = DBConnection.getConnection();
                         Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT isbn, title FROM book")) {
                        while (rs.next()) {
                %>
                    <option value="<%= rs.getString("isbn") %>">
                        <%= rs.getString("title") %> (<%= rs.getString("isbn") %>)
                    </option>
                    <option value="<%= rs.getString("title") %>">
                        <%= rs.getString("title") %> (<%= rs.getString("isbn") %>)
                    </option>
                <%
                        }
                    }
                %>
            </datalist><br><br>

            Vị trí (Kệ) 
            <select name="rackId" required>
                <option value="">-- Chọn kệ --</option>
                <%
                    try (Connection conn = DBConnection.getConnection();
                         Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT rack_id, rack_number FROM rack")) {
                        while (rs.next()) {
                %>
                    <option value="<%= rs.getInt("rack_id") %>">
                        <%= rs.getString("rack_number") %>
                    </option>
                <%
                        }
                    }
                %>
            </select><br><br>
            <input class="btn" type="submit" value="Thêm Vị Trí Sách">
        </form>
    </div>   
</body>
</html>
