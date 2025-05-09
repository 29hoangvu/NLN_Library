<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="Data.Users" %>
<%
    Users user = (Users) session.getAttribute("user");

    // Kiểm tra nếu chưa đăng nhập hoặc không có quyền truy cập
    if (user == null || (user.getRoleID() != 1 && user.getRoleID() != 2)) {
        response.sendRedirect("index.jsp"); // Chuyển về trang chính nếu không có quyền
        return;
    }
%>
<html>
<head>
    <title>Quản lý sách - Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />
    <link rel="stylesheet" href="./CSS/ad_menu.css">
    <link rel="stylesheet" href="./CSS/navbar.css">
    <script src="./JS/admin.js"></script> 
    <style>
        /* CSS chung */
        html, body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background-color: #f4f4f4;
            display: block;
        }

        /* Bảng sách */
        table {
            width: 90%;
            border-collapse: collapse;
            margin-left: 11%;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
        }

        th, td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: center;
        }

        th {
            background-color: #2c3e50;
            color: white;
        }

        tr:hover {
            background-color: #aaf0f0;
        }

        /* Nút chỉnh sửa & xóa */
        .btn-edit, .btn-delete {
            padding: 8px 12px;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-weight: bold;
            display: inline-block;
        }

        .btn-edit {
            background-color: #2ecc71;
        }

        .btn-delete {
            background-color: #e74c3c;
        }
        /* Phân trang */
        .pagination {
            list-style: none;
            padding: 10px;
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }

        .pagination li {
            margin: 0 5px;
        }

        .pagination a {
            text-decoration: none;
            padding: 10px 15px;
            background: #3498db;
            color: white;
            border-radius: 5px;
            transition: 0.3s;
            font-weight: bold;
        }

        .pagination a:hover {
            background: #2980b9;
        }

        .pagination .active a {
            background: #2c3e50;
        }
        /* Thanh tìm kiếm */
        .search-container {
            text-align: center;
            margin: 10px 0 10px 0;
        }

        .search-container input {
            width: 50%;
            padding: 10px;
            font-size: 16px;
            border: 1px solid #ddd;
            border-radius: 5px;
            outline: none;
        }

        .search-container button {
            padding: 10px 15px;
            font-size: 16px;
            background-color: #3498db;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: 0.3s;
        }

        .search-container button:hover {
            background-color: #2980b9;
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
     <!-- Thanh tìm kiếm -->
    <div class="search-container">
        <form action="adminDashboard.jsp" method="POST">
            <input type="text" name="search" placeholder="Nhập ISBN, tên sách hoặc tác giả..." 
                   value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
            <button type="submit"><i class="fa fa-search"></i> Tìm kiếm</button>
        </form>
    </div>
    <div class="content">
        <%
            // Thông tin kết nối MySQL
            String jdbcURL = "jdbc:mysql://localhost:3306/qlthuvien";
            String jdbcUsername = "root";
            String jdbcPassword = "";

            // Biến phân trang
            int booksPerPage = 20;
            int currentPage = 1;
            if (request.getParameter("page") != null) {
                currentPage = Integer.parseInt(request.getParameter("page"));
            }
            int startIndex = (currentPage - 1) * booksPerPage;

            List<Map<String, String>> books = new ArrayList<>();
            int totalBooks = 0;
            String searchQuery = request.getParameter("search") != null ? request.getParameter("search").trim() : "";

            try {
                // Kết nối database
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

                // Đếm tổng số sách
                String countSQL = "SELECT COUNT(*) FROM book b " +
                                "JOIN author a ON b.authorId = a.id " +
                                "WHERE b.status != 'DELETED' ";
                if (!searchQuery.isEmpty()) {
                    countSQL += "AND (b.isbn LIKE ? OR b.title LIKE ? OR a.name LIKE ?)";
                }

                PreparedStatement countStmt = conn.prepareStatement(countSQL);
                if (!searchQuery.isEmpty()) {
                    for (int i = 1; i <= 3; i++) {
                        countStmt.setString(i, "%" + searchQuery + "%");
                    }
                }
                ResultSet countRs = countStmt.executeQuery();
                if (countRs.next()) {
                    totalBooks = countRs.getInt(1);
                }
                countRs.close();
                countStmt.close();

                // Lấy danh sách sách
                String query = "SELECT b.isbn, b.title, a.name AS author, r.rack_number, b.quantity " +
                                "FROM book b " +
                                "JOIN author a ON b.authorId = a.id " +
                                "LEFT JOIN bookitem bi ON b.isbn = bi.book_isbn " +
                                "LEFT JOIN rack r ON bi.rack_id = r.rack_id " +
                                "WHERE b.status != 'DELETED' ";
                if (!searchQuery.isEmpty()) {
                    query += "AND (b.isbn LIKE ? OR b.title LIKE ? OR a.name LIKE ?) ";
                }

                query += "ORDER BY CASE WHEN r.rack_number IS NULL THEN 1 ELSE 0 END, r.rack_number ASC " + 
                        "LIMIT ?, ?";

                PreparedStatement stmt = conn.prepareStatement(query);
                int paramIndex = 1;
                if (!searchQuery.isEmpty()) {
                    for (int i = 1; i <= 3; i++) {
                        stmt.setString(paramIndex++, "%" + searchQuery + "%");
                    }
                }
                stmt.setInt(paramIndex++, startIndex);
                stmt.setInt(paramIndex, booksPerPage);
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    Map<String, String> book = new HashMap<>();
                    book.put("isbn", rs.getString("isbn"));
                    book.put("title", rs.getString("title"));
                    book.put("author", rs.getString("author"));
                    book.put("rack", rs.getString("rack_number") != null ? rs.getString("rack_number") : "Chưa sắp xếp");
                    book.put("quantity", rs.getString("quantity"));
                    books.add(book);
                }
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("<p style='color:red;'>Lỗi: " + e.getMessage() + "</p>");
            }

            int totalPages = (int) Math.ceil((double) totalBooks / booksPerPage);
        %>

    <!-- Hiển thị bảng sách -->
    <table>
        <tr>
            <th>ISBN</th>
            <th>Tên sách</th>
            <th>Tác giả</th>
            <th>Kệ sách</th>
            <th>Số lượng</th>
            <th>Sửa</th>
            <th>Xóa</th>
        </tr>
        <% for (Map<String, String> book : books) { %>
        <tr>
            <td><%= book.get("isbn") %></td>
            <td><%= book.get("title") %></td>
            <td><%= book.get("author") %></td>
            <td><%= book.get("rack") %></td>
            <td><%= book.get("quantity") %></td>
            <td>
                <a href="editBook.jsp?isbn=<%= book.get("isbn") %>" class="btn-edit">
                    <i class="fas fa-edit"></i>
                </a>
            </td>
            <td>
                <a href="DeleteBookServlet?isbn=<%= book.get("isbn") %>" class="btn-delete" 
                   onclick="return confirm('Bạn có chắc muốn xóa sách này không?');">
                    <i class="fas fa-trash-alt"></i>
                </a>
            </td>

        </tr>
        <% } %>
    </table>

    <script>
        function deleteBook(isbn) {
            if (!confirm("Bạn có chắc muốn xóa sách này?")) return;

            fetch("deleteBookServlet", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "isbn=" + encodeURIComponent(isbn)
            })
            .then(response => response.json())
            .then(data => {
                alert(data.message);
                if (data.status === "success") {
                    location.reload(); // Tải lại trang sau khi xóa thành công
                }
            })
            .catch(error => console.error("Lỗi:", error));
        }    
    </script>
    <ul class="pagination">
        <% if (currentPage > 1) { %>
            <li><a href="adminDashboard.jsp?page=<%= currentPage - 1 %>">« Trước</a></li>
        <% } %>

        <% for (int i = 1; i <= totalPages; i++) { %>
            <li class="<%= (i == currentPage) ? "active" : "" %>">
                <a href="adminDashboard.jsp?page=<%= i %>"><%= i %></a>
            </li>
        <% } %>

        <% if (currentPage < totalPages) { %>
            <li><a href="adminDashboard.jsp?page=<%= currentPage + 1 %>">Tiếp »</a></li>
        <% } %>
    </ul>
</body>
</html>