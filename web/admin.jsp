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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Quản lý sách - Admin</title>
    <link rel="stylesheet" href="./CSS/admin1.css">
    <link rel="stylesheet" href="./CSS/ad_menu.css">
    <script src="./JS/admin.js"></script> 
    <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />
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
        <h2>Thêm sách mới</h2>
        <form class="form" action="AdminServlet" method="post" enctype="multipart/form-data" class="book-form">
            <div class="row">
                <div class="col"><label>ISBN</label><input type="text" name="isbn" required></div>
                <div class="col"><label>Tên sách</label><input type="text" name="title" required></div>
            </div>
            <div class="row">
                <div class="col"><label>Thể loại</label><input type="text" name="subject"></div>
                <div class="col"><label>Nhà xuất bản</label><input type="text" name="publisher"></div>
            </div>
            <div class="row">
                <div class="col"><label>Năm xuất bản</label><input type="number" name="publicationYear" min="1000" max="9999" required></div>
                <div class="col"><label>Ngôn ngữ</label><input type="text" name="language"></div>
            </div>
            <div class="row">
                <div class="col"><label>Số trang</label><input type="number" name="numberOfPages" min="1"></div>
                <div class="col">
                    <label>Định dạng</label>
                    <select name="format">
                        <option value="HARDCOVER">Bìa cứng</option>
                        <option value="PAPERBACK">Bìa mềm</option>
                        <option value="EBOOK">Ebook</option>
                    </select>
                </div>
            </div>
            <div class="row">
                <div class="col">
                    <label>Tác giả</label>
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
                </div>
                <div class="col"><label>Số lượng</label><input type="number" name="quantity" min="1" required></div>
            </div>
            <div class="row">
                <div class="col"><label>Giá sách</label><input type="number" name="price" step="0.01" min="0" required></div>
                <div class="col"><label>Ngày nhập</label><input type="date" name="dateOfPurchase" required></div>
            </div>
            <div class="row">
                <div class="col"><label>Hình ảnh</label><input type="file" name="coverImage" accept="image/*"></div>
            </div>
            <button class="btn" type="submit">Thêm sách</button>
        </form>
                    
    </div>
</body>
<script>
document.getElementById("authorName").addEventListener("input", function () {
    const input = this.value.trim();
    const dataList = document.getElementById("authorList");
    let isExistingAuthor = false;

    for (let option of dataList.options) {
        if (option.value === input) {
            document.getElementById("authorId").value = option.dataset.id;
            isExistingAuthor = true;
            break;
        }
    }

    if (isExistingAuthor) {
        document.getElementById("isNewAuthor").value = "false";
    } else {
        document.getElementById("isNewAuthor").value = "true";
        document.getElementById("authorId").value = "";
    }
});
</script>
</html>

