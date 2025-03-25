package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ReturnBookServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int borrowId = Integer.parseInt(request.getParameter("id"));
        double finePerDay = 5000; // Phí phạt mỗi ngày trễ

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Lấy thông tin ngày hạn trả và book_item_id từ bảng borrow
            String selectSql = "SELECT due_date, book_item_id FROM borrow WHERE borrow_id = ?";
            PreparedStatement selectStmt = conn.prepareStatement(selectSql);
            selectStmt.setInt(1, borrowId);
            ResultSet rs = selectStmt.executeQuery();

            if (rs.next()) {
                LocalDate dueDate = rs.getDate("due_date").toLocalDate();
                int bookItemId = rs.getInt("book_item_id");
                LocalDate returnDate = LocalDate.now();

                // Tính số ngày trễ hạn
                long overdueDays = ChronoUnit.DAYS.between(dueDate, returnDate);
                double fineAmount = (overdueDays > 0) ? overdueDays * finePerDay : 0;

                // 2. Lấy `book_isbn` từ bảng `bookitem`
                String getBookSql = "SELECT book_isbn FROM bookitem WHERE book_item_id = ?";
                PreparedStatement getBookStmt = conn.prepareStatement(getBookSql);
                getBookStmt.setInt(1, bookItemId);
                ResultSet bookRs = getBookStmt.executeQuery();

                if (bookRs.next()) {
                    String bookIsbn = bookRs.getString("book_isbn");

                    // 3. Cập nhật trạng thái trả sách và tiền phạt trong bảng `borrow`
                    String updateBorrowSql = "UPDATE borrow SET return_date = NOW(), status = 'Returned', fine_amount = ? WHERE borrow_id = ?";
                    PreparedStatement updateBorrowStmt = conn.prepareStatement(updateBorrowSql);
                    updateBorrowStmt.setDouble(1, fineAmount);
                    updateBorrowStmt.setInt(2, borrowId);
                    int updated = updateBorrowStmt.executeUpdate();

                    if (updated > 0) {
                        // 4. Cập nhật số lượng sách trong bảng `book`
                        String updateBookSql = "UPDATE book SET quantity = quantity + 1 WHERE isbn = ?";
                        PreparedStatement updateBookStmt = conn.prepareStatement(updateBookSql);
                        updateBookStmt.setString(1, bookIsbn);
                        updateBookStmt.executeUpdate();

                        response.getWriter().write("Xác nhận trả thành công" + (fineAmount > 0 ? ", phạt " + fineAmount + " VNĐ" : ""));
                    } else {
                        response.getWriter().write("Lỗi khi xác nhận trả");
                    }
                } else {
                    response.getWriter().write("Không tìm thấy sách trong hệ thống");
                }
            } else {
                response.getWriter().write("Không tìm thấy thông tin mượn sách");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("Lỗi SQL: " + e.getMessage());
        }
    }
}
