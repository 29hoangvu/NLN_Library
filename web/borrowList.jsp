<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, Servlet.DBConnection" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="Data.Users" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý mượn sách</title>
    <script>
        function approveBorrow(borrowId, bookItemId) {
            if (confirm("Bạn có chắc chắn muốn duyệt yêu cầu mượn sách này?")) {
                window.location.href = "ApproveBorrowServlet?borrowId=" + borrowId + "&bookItemId=" + bookItemId;
            }
        }
    </script>
</head>
<body>
    <h2>Danh sách yêu cầu mượn sách</h2>
    <table border="1">
        <tr>
            <th>Người mượn</th>
            <th>Tên sách</th>
            <th>ISBN</th>
            <th>Ngày mượn</th>
            <th>Ngày hết hạn</th>
            <th>Trạng thái</th>
            <th>Hành động</th>
        </tr>
        <%
            Connection conn = DBConnection.getConnection();
            String sql = "SELECT b.borrow_id, u.username, bk.title, bk.isbn, b.borrowed_date, b.due_date, b.status, b.book_item_id " +
                         "FROM borrow b " +
                         "JOIN users u ON b.user_id = u.id " +
                         "JOIN bookitem bi ON b.book_item_id = bi.book_item_id " +
                         "JOIN book bk ON bi.book_isbn = bk.isbn " +  
                         "WHERE b.status = 'Chờ duyệt'";
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getString("username") %></td>
            <td><%= rs.getString("title") %></td>
            <td><%= rs.getString("isbn") %></td>
            <td><%= rs.getDate("borrowed_date") %></td>
            <td><%= rs.getDate("due_date") %></td>
            <td><%= rs.getString("status") %></td>
            <td>
                <button onclick="approveBorrow(<%= rs.getInt("borrow_id") %>, <%= rs.getInt("book_item_id") %>)">
                    Duyệt
                </button>
            </td>
        </tr>
        <%
            }
            conn.close();
        %>
    </table>
</body>
</html>
