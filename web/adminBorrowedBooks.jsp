<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, Servlet.DBConnection" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="Data.Users" %>
<%
    Users user = (Users) session.getAttribute("user");

    // Kiểm tra nếu chưa đăng nhập hoặc không có quyền truy cập
    if (user == null || (user.getRoleID() != 1 && user.getRoleID() != 2)) {
        response.sendRedirect("index.jsp"); // Chuyển về trang chính nếu không có quyền
        return;
    }

    // Định dạng ngày tháng năm
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Mượn/Trả</title>
    <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />
    <link rel="stylesheet" href="./CSS/admin1.css">
    <link rel="stylesheet" href="./CSS/table_ad.css">
    <link rel="stylesheet" href="./CSS/ad_menu.css">
    <script src="./JS/adminBorrowedBooks.js"></script>
    <script src="./JS/admin.js"></script>
    <style>
        .nav-buttons {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin: 10px 0 20px -10%;
        }
        .nav-buttons a {
            padding: 10px 15px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
        .nav-buttons a:hover {
            background-color: #0056b3;
        }
    </style>
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
        <!-- Nút điều hướng -->
        <div class="nav-buttons">         
            <a href="adminBorrowedBooks.jsp">Quản lý Mượn/Trả</a>
            <a href="borrowList.jsp">Duyệt Mượn Sách</a>
            <a href="adminReports.jsp">Thống kê</a>
        </div>
        <table border="1">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Người Mượn</th>
                    <th>Sách</th>
                    <th>Ngày Mượn</th>
                    <th>Hạn Trả</th>
                    <th>Ngày Trả</th>
                    <th>Trạng Thái</th>
                    <th>Tiền Phạt</th>
                    <th>Thao Tác</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    Connection conn = DBConnection.getConnection();
                    Statement stmt = conn.createStatement();
                    String sql = "SELECT b.borrow_id, u.username, bk.title, bk.isbn, " +
                                 "b.borrowed_date, b.due_date, b.return_date, " +
                                 "b.status, b.fine_amount, b.book_item_id " +
                                 "FROM borrow b " +
                                 "JOIN users u ON b.user_id = u.id " +
                                 "JOIN bookitem bi ON b.book_item_id = bi.book_item_id " +
                                 "JOIN book bk ON bi.book_isbn = bk.isbn " +
                                 "WHERE b.status != 'Pending Approval'";  // Không hiển thị sách chờ duyệt

                    ResultSet rs = stmt.executeQuery(sql);
                    while (rs.next()) {
                        String status = rs.getString("status");
                        String statusText = "";
                        if (status.equals("Borrowed")) {
                            statusText = "Đang mượn";
                        } else if (status.equals("Overdue")) {
                            statusText = "Trễ hạn";
                        } else if (status.equals("Returned")) {
                            statusText = "Đã trả";
                        } else if (status.equals("Lost")) {
                            statusText = "Mất sách";
                        }
                        
                        // Lấy dữ liệu ngày từ CSDL
                        java.sql.Date borrowedDate = rs.getDate("borrowed_date");
                        java.sql.Date dueDate = rs.getDate("due_date");
                        java.sql.Date returnDate = rs.getDate("return_date");

                        // Chuyển đổi sang định dạng dd/MM/yyyy
                        String borrowedDateStr = (borrowedDate != null) ? dateFormat.format(borrowedDate) : "N/A";
                        String dueDateStr = (dueDate != null) ? dateFormat.format(dueDate) : "N/A";
                        String returnDateStr = (returnDate != null) ? dateFormat.format(returnDate) : "Chưa trả";
                %>
                <tr>
                    <td><%= rs.getInt("borrow_id") %></td>
                    <td><%= rs.getString("username") %></td>
                    <td><%= rs.getString("title") %></td>
                    <td><%= borrowedDateStr %></td>
                    <td><%= dueDateStr %></td>
                    <td><%= returnDateStr %></td>
                    <td><%= statusText %></td>
                    <td><%= (rs.getObject("fine_amount") != null) ? rs.getDouble("fine_amount") : 0 %> VNĐ</td>
                    <td>
                        <% if (status.equals("Borrowed")) { %>
                        <button class="btn-edit" onclick="confirmReturn(<%= rs.getInt("borrow_id") %>)">Xác nhận Trả</button>
                        <% } else if (status.equals("Overdue")) { %>
                            <button class="btn-edit" onclick="confirmReturn(<%= rs.getInt("borrow_id") %>)">Xác nhận Trả</button>
                        <% } %>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</body>
</html>
