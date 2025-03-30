function confirmReturn(borrowId) {
    if (confirm("Xác nhận sách đã được trả?")) {
        fetch('ReturnBookServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'id=' + borrowId
        }).then(response => response.text()).then(data => {
            alert(data);
            location.reload();
        }).catch(error => console.error('Error:', error));
    }
}



