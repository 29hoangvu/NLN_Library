<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, Servlet.DBConnection" %><!DOCTYPE html>

<html>
<head>
    <meta charset="UTF-8">
    <title>Thêm Vị Trí Sách</title>
    <link rel="stylesheet" href="./CSS/admin.css">
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
            <li><a href="createUser.jsp">Quản lý người dùng</a></li>
        </ul>
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

        <form action="BookItemServlet" method="post">
            ISBN hoặc Tên sách: 
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

            Vị trí (Kệ): 
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
            <input type="submit" value="Thêm Vị Trí Sách">
        </form>
    </div>   
</body>
</html>
