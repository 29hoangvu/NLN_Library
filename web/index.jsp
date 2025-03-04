<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, Servlet.DBConnection, Data.Users" %>
<%@ page session="true" %>
<html>
<head>
    <title>Thư viện Sách</title>
    <link rel="stylesheet" href="./CSS/index.css">
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="user-menu">
                <%
                     Users user = (Users) session.getAttribute("user");
                    if (user != null) {
                %>
                    <span>Xin chào, <%= user.getUsername() %>!</span>
                    <div class="logout-button">
                         <form action="./LogOutServlet" method="get">
                            <button onclick="logout()">Đăng xuất</button>
                        </form>
                    </div>
                <%
                    } else {
                %>
                    <a href="login.jsp" class="btn">Đăng nhập</a>
                <%
                    }
                %>
            </div>

            <h1>Thư viện sách</h1>
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

                try {
                    conn = DBConnection.getConnection();
                    String sql = "SELECT b.isbn, b.title, a.name AS author, b.publicationYear, b.format " +
                                 "FROM book b " +
                                 "LEFT JOIN author a ON b.authorId = a.id ";
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery(sql);

                    while (rs.next()) {
                        Map<String, Object> book = new HashMap<>();
                        book.put("isbn", rs.getString("isbn")); // Thêm isbn
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

            <h3>Sách Bìa Cứng</h3>
            <div class="books-container">
                <% 
                    boolean hasHardcover = false;
                    for (Map<String, Object> book : books) {
                        if ("HARDCOVER".equals(book.get("format"))) {
                            hasHardcover = true;
                %>
                        <div class="book-card">
                            <a href="bookDetails.jsp?isbn=<%= book.get("isbn") %>">
                                <img src="ImageServlet?isbn=<%= book.get("isbn") %>" alt="Ảnh bìa" />
                            </a>
                            <h3><%= book.get("title") %></h3>
                            <p><strong>Tác giả:</strong> <%= book.get("author") %></p>
                            <p><strong>Năm xuất bản:</strong> <%= book.get("publishedYear") %></p>
                        </div>
                <% 
                        }
                    } 
                    if (!hasHardcover) {
                %>
                    <p>Không có sách bìa cứng.</p>
                <% } %>
            </div>

            <h3>Sách Bìa Mềm</h3>
            <div class="books-container">
                <% 
                    boolean hasPaperback = false;
                    for (Map<String, Object> book : books) {
                        if ("PAPERBACK".equals(book.get("format"))) {
                            hasPaperback = true;
                %>
                        <div class="book-card">
                            <a href="bookDetails.jsp?isbn=<%= book.get("isbn") %>">
                                <img src="ImageServlet?isbn=<%= book.get("isbn") %>" alt="Ảnh bìa" />
                            </a>
                            <h3><%= book.get("title") %></h3>
                            <p><strong>Tác giả:</strong> <%= book.get("author") %></p>
                            <p><strong>Năm xuất bản:</strong> <%= book.get("publishedYear") %></p>
                        </div>
                <% 
                        }
                    } 
                    if (!hasPaperback) {
                %>
                    <p>Không có sách bìa mềm.</p>
                <% } %>
            </div>

            <h3>Ebook</h3>
            <div class="books-container">
                <% 
                    boolean hasEbook = false;
                    for (Map<String, Object> book : books) {
                        if ("EBOOK".equals(book.get("format"))) {
                            hasEbook = true;
                %>
                        <div class="book-card">
                            <a href="bookDetails.jsp?isbn=<%= book.get("isbn") %>">
                                <img src="ImageServlet?isbn=<%= book.get("isbn") %>" alt="Ảnh bìa" />
                            </a>
                            <h3><%= book.get("title") %></h3>
                            <p><strong>Tác giả:</strong> <%= book.get("author") %></p>
                            <p><strong>Năm xuất bản:</strong> <%= book.get("publishedYear") %></p>
                        </div>
                <% 
                        }
                    } 
                    if (!hasEbook) {
                %>
                    <p>Không có Ebook.</p>
                <% } %>
            </div>
        </div>
        <div class="footer">
            
        </div>
    </div>
</body>
</html>
