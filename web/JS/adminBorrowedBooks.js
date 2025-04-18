function confirmReturn(borrowId) {
    if (confirm("Bạn có chắc muốn xác nhận trả sách không?")) {
        fetch('ReturnBookServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'id=' + borrowId
        })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            window.location.href = data.redirect;
        })
        .catch(err => {
            alert("Lỗi khi xác nhận trả sách.");
            console.error(err);
        });
    }
}

