<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, Servlet.DBConnection" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Danh Sách Người Dùng</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>

    <h2>Danh Sách Người Dùng</h2>

    <table>
        <tr>
            <th>ID</th>
            <th>Tên đăng nhập</th>
            <th>Trạng thái</th>
            <th>Ngày hết hạn</th>
            <th>Vai trò</th>
        </tr>
        <%
            Connection conn = DBConnection.getConnection();
            if (conn == null) {
                out.println("<p style='color:red;'>Không thể kết nối database!</p>");
            } else {
                String sql = "SELECT u.id, u.username, u.status, u.expiryDate, r.role_name " +
                             "FROM Users u JOIN Role r ON u.roleID = r.id";
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql);
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getString("username") %></td>
            <td><%= rs.getString("status") %></td>
            <td><%= rs.getDate("expiryDate") %></td>
            <td><%= rs.getString("role_name") %></td>
        </tr>
        <%
                }
                rs.close();
                stmt.close();
                conn.close();
            }
        %>
    </table>

</body>
</html>
