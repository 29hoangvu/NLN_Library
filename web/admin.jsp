<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, Servlet.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Quản lý sách - Admin</title>
    <link rel="stylesheet" href="./CSS/admin.css">
    <script>
        // Gộp chọn/nhập tác giả trong cùng 1 ô
        document.addEventListener('DOMContentLoaded', () => {
            const authorInput = document.getElementById('authorName');
            const authorList = document.getElementById('authorList');
            const authorIdInput = document.getElementById('authorId');
            const isNewAuthorInput = document.getElementById('isNewAuthor');

            authorInput.addEventListener('input', () => {
                const inputVal = authorInput.value.trim();
                let found = false;
                for (const opt of authorList.options) {
                    if (opt.value === inputVal) {
                        authorIdInput.value = opt.dataset.id;
                        isNewAuthorInput.value = "false";
                        found = true;
                        break;
                    }
                }
                if (!found && inputVal !== "") {
                    authorIdInput.value = "";
                    isNewAuthorInput.value = "true";
                }
            });
        });
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
        <h2>Thêm sách mới</h2>
        <form action="AdminServlet" method="post" enctype="multipart/form-data">
            ISBN <input type="text" name="isbn" required>
            Tên sách <input type="text" name="title" required>
            Chủ đề <input type="text" name="subject">
            Nhà xuất bản <input type="text" name="publisher">
            Năm xuất bản <input type="number" name="publicationYear" min="1000" max="9999" required>
            Ngôn ngữ <input type="text" name="language">
            Số trang <input type="number" name="numberOfPages" min="1">
            Định dạng 
            <select name="format">
                <option value="HARDCOVER">Bìa cứng</option>
                <option value="PAPERBACK">Bìa mềm</option>
                <option value="EBOOK">Ebook</option>
            </select>

            <!-- Ô nhập gộp cho tác giả -->
            Tác giả
            <input type="text" name="authorName" id="authorName" list="authorList" placeholder="Nhập hoặc chọn tác giả" required>
            <datalist id="authorList">
                <% 
                    Connection conn = DBConnection.getConnection();
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT id, name FROM Author");
                    while (rs.next()) {
                %>
                <option value="<%= rs.getString("name") %>" data-id="<%= rs.getInt("id") %>"></option>
                <% } %>
            </datalist>

            <input type="hidden" name="authorId" id="authorId">
            <input type="hidden" name="isNewAuthor" id="isNewAuthor" value="false">

            Số lượng <input type="number" name="quantity" min="1" required>
            Hình ảnh <input type="file" name="coverImage" accept="image/*">

            <button type="submit">Thêm sách</button>
        </form>
    </div>
</body>
</html>
