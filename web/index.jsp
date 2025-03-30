<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, Servlet.DBConnection, Data.Users" %>
<html>
<head>
    <title>Thư viện Sách</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="./CSS/home.css">
    <script src="./JS/home.js"></script>
    <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />
    <style>
        .h1{
            float: left; 
            margin-right: 10%;
            margin-left: 10px;
            font-size: 2.5rem;
            margin-top: 15px;
            color: #fff;
            background: url('./images/nen2.jpg') center;
            background-size: cover;
            background-clip: text;
            color: transparent;
            animation: animate 10s linear infinite;
        }
        @keyframes animate{
            to{
                background-position-x: -200px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <a href="index.jsp">
                <h1 class="h1">LIBRARY</h1>
            </a>
            <form action="index.jsp" method="get" class="search-form">
                <input type="text" name="search" placeholder="Tìm sách theo tên hoặc tác giả..." 
                       value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                <button type="submit">Tìm kiếm</button>
            </form>
            <div class="user-menu" style="float: right; position: relative;">
                <%
                    Users user = (Users) session.getAttribute("user");
                    if (user != null) {
                        String avatarUrl = "AvatarServlet?userId=" + user.getId();
                        String defaultAvatar = "./images/default-avatar.png"; // Ảnh mặc định
                %>
                    <div class="dropdown">
                        <img src="<%= avatarUrl %>" onerror="this.onerror=null; this.src='<%= defaultAvatar %>';" 
                             alt="Avatar" class="avatar" onclick="toggleDropdown()">
                        <div class="dropdown-content" id="userDropdown">
                            <div class="user-info">
                                <img src="<%= avatarUrl %>" onerror="this.onerror=null; this.src='<%= defaultAvatar %>';" 
                                     alt="Avatar" class="avatar-large">
                                <p><%= user.getUsername() %></p>
                            </div>
                            <a href="#">Xem thông tin</a>
                            <a href="borrowedBooks.jsp">Sách đã mượn</a>
                            <a href="LogOutServlet">Đăng xuất</a>
                        </div>
                    </div>
                <%
                    } else {
                %>
                    <a href="login.jsp" class="btn-login" title="Đăng nhập">
                        <i class="fas fa-sign-in-alt"></i>
                    </a>
                <%
                    }
                %>
            </div>
        </div>
        
        <div class="menu">          
            <div class="menu-navbar">
                <ul>
                    <li><a href="#hardcover">Sách Bìa Cứng</a></li>
                    <li><a href="#paperback">Sách Bìa Mềm</a></li>
                    <li><a href="#ebook">Ebook</a></li>
                </ul>
            </div>   
        </div>
        
        <div class="content">
            <%
                Connection conn = null;
                List<Map<String, Object>> books = new ArrayList<>();
                String searchQuery = request.getParameter("search");

                try {
                    conn = DBConnection.getConnection();
                    String sql = "SELECT b.isbn, b.title, a.name AS author, b.publicationYear, b.format " +
                                 "FROM book b " +
                                 "LEFT JOIN author a ON b.authorId = a.id";

                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        String[] keywords = searchQuery.trim().toLowerCase().split("\\s+"); // Tách từ khóa nhập vào
                        StringBuilder sqlCondition = new StringBuilder(" WHERE ");

                        for (int i = 0; i < keywords.length; i++) {
                            if (i > 0) sqlCondition.append(" AND "); // Mỗi từ phải xuất hiện
                            sqlCondition.append("(LOWER(b.title) LIKE ? OR LOWER(a.name) LIKE ?)");
                        }

                        sql += sqlCondition.toString();
                    }

                    PreparedStatement stmt = conn.prepareStatement(sql);

                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        String[] keywords = searchQuery.trim().toLowerCase().split("\\s+");
                        int index = 1;
                        for (String keyword : keywords) {
                            String param = "%" + keyword + "%";
                            stmt.setString(index++, param);
                            stmt.setString(index++, param);
                        }
                    }

                    ResultSet rs = stmt.executeQuery();

                    while (rs.next()) {
                        Map<String, Object> book = new HashMap<>();
                        book.put("isbn", rs.getString("isbn"));
                        book.put("title", rs.getString("title"));
                        book.put("author", rs.getString("author"));
                        book.put("publishedYear", rs.getInt("publicationYear"));
                        book.put("format", rs.getString("format"));
                        books.add(book);
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<p style='color:red;'>Lỗi khi lấy dữ liệu sách: " + e.getMessage() + "</p>");
                } finally {
                    if (conn != null) {
                        try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                }
            %>

            <!-- Sách Bìa Cứng -->
        <div class="category-header">
            <h3 id="hardcover">Sách Bìa Cứng</h3>
            <button class="show-more-btn" onclick="toggleView('hardcover-books', this)">Xem thêm</button>
        </div>
        <div class="books-container" id="hardcover-books">
            <% for (Map<String, Object> book : books) { %>
                <% if ("HARDCOVER".equals(book.get("format"))) { %>
                    <div class="book-card">
                        <a href="bookDetails.jsp?isbn=<%= book.get("isbn") %>">
                            <img src="ImageServlet?isbn=<%= book.get("isbn") %>" alt="Ảnh bìa" />
                        </a>
                        <h3><%= book.get("title") %></h3>
                        <p><strong>Tác giả:</strong> <%= book.get("author") %></p>
                        <p><strong>Năm xuất bản:</strong> <%= book.get("publishedYear") %></p>
                    </div>
                <% } %>
            <% } %>
        </div>

        <!-- Sách Bìa Mềm -->
        <div class="category-header">
            <h3 id="paperback">Sách Bìa Mềm</h3>
            <button class="show-more-btn" onclick="toggleView('paperback-books', this)">Xem thêm</button>
        </div>
        <div class="books-container" id="paperback-books">
            <% for (Map<String, Object> book : books) { %>
                <% if ("PAPERBACK".equals(book.get("format"))) { %>
                    <div class="book-card">
                        <a href="bookDetails.jsp?isbn=<%= book.get("isbn") %>">
                            <img src="ImageServlet?isbn=<%= book.get("isbn") %>" alt="Ảnh bìa" />
                        </a>
                        <h3><%= book.get("title") %></h3>
                        <p><strong>Tác giả:</strong> <%= book.get("author") %></p>
                        <p><strong>Năm xuất bản:</strong> <%= book.get("publishedYear") %></p>
                    </div>
                <% } %>
            <% } %>
        </div>

        <!-- Ebook -->
        <div class="category-header">
            <h3 id="ebook">Ebook</h3>
            <button class="show-more-btn" onclick="toggleView('ebook-books', this)">Xem thêm</button>
        </div>
        <div class="books-container" id="ebook-books">
            <% for (Map<String, Object> book : books) { %>
                <% if ("EBOOK".equals(book.get("format"))) { %>
                    <div class="book-card">
                        <a href="bookDetails.jsp?isbn=<%= book.get("isbn") %>">
                            <img src="ImageServlet?isbn=<%= book.get("isbn") %>" alt="Ảnh bìa" />
                        </a>
                        <h3><%= book.get("title") %></h3>
                        <p><strong>Tác giả:</strong> <%= book.get("author") %></p>
                        <p><strong>Năm xuất bản:</strong> <%= book.get("publishedYear") %></p>
                    </div>
                <% } %>
            <% } %>
        </div>
    </div>
        
        <div class="footer">
            <p>Bản quyền &copy; 2025 - Thư viện sách</p>
        </div>
    </div>
</body>
</html>
