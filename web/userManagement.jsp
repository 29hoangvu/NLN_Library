<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, Servlet.DBConnection" %>
<html>
<head>
    <title>Quản lý Người Dùng</title>
    <style>
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid black; padding: 10px; text-align: center; }
        th { background-color: #f2f2f2; }
        button { padding: 5px 10px; cursor: pointer; }
    </style>
</head>
<body>
    <h2>Danh sách Người Dùng</h2>
    <table>
        <tr>
            <th>ID</th>
            <th>Tên đăng nhập</th>
            <th>Trạng thái</th>
            <th>Hạn sử dụng</th>
            <th>Vai trò</th>
            <th>Hành động</th>
        </tr>
        <%
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT u.id, u.username, u.status, u.expiryDate, r.roleName " +
                             "FROM users u JOIN role r ON u.roleID = r.id";
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    int userID = rs.getInt("id");
                    String username = rs.getString("username");
                    String status = rs.getString("status");
                    String expiryDate = rs.getString("expiryDate");
                    String role = rs.getString("roleName");
        %>
        <tr>
            <td><%= userID %></td>
            <td><%= username %></td>
            <td><%= status %></td>
            <td><%= (expiryDate != null) ? expiryDate : "Không có" %></td>
            <td><%= role %></td>
            <td>
                <% if (status.equals("PENDING")) { %>
                    <form action="ApproveUserServlet" method="post" style="display:inline;">
                        <input type="hidden" name="userID" value="<%= userID %>">
                        <button type="submit">Duyệt</button>
                    </form>
                <% } %>

                <% if (status.equals("EXPIRED")) { %>
                    <form action="RenewServlet" method="post" style="display:inline;">
                        <input type="hidden" name="userID" value="<%= userID %>">
                        <button type="submit">Gia hạn</button>
                    </form>
                <% } %>
            </td>
        </tr>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
    </table>
</body>
</html>
