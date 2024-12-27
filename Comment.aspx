<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="Comment.aspx.cs" Inherits="fyp.Comment" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rating & Comment Page</title>
        <link rel="stylesheet" href="assets/css/comment.css" />
         <link rel="stylesheet" href="assets/css/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">
</head>
<body>
   <style>
               .back-button {
    cursor: pointer;
    width: 50px;
    height: 50px;
    border: none;
    /* Add more styling as needed */
}
   </style>

        <div class="comment-page-container">
        <h2>Rate & Comment</h2>

        <!-- Rating Section -->
        <div class="rating-container">
            <p>Rate this:</p>
            <div class="star-rating">
                <span class="star <%= rateStars >= 1 ? "active" : "" %>" data-value="1">&#9733;</span>
                <span class="star <%= rateStars >= 2 ? "active" : "" %>" data-value="2">&#9733;</span>
                <span class="star <%= rateStars >= 3 ? "active" : "" %>" data-value="3">&#9733;</span>
                <span class="star <%= rateStars >= 4 ? "active" : "" %>" data-value="4">&#9733;</span>
                
                <span class="star <%= rateStars >= 5 ? "active" : "" %>" data-value="5">&#9733;</span>
                
            </div>
        </div>

        <!-- Comment Section -->
        <div class="comment-container">
            <textarea id="comment-box" placeholder="Leave your comment here..."><%= rateComment %></textarea>
            <button class="submit-btn" id="submit-btn">Submit</button>

          <button class="cancel-btn" type="button" onclick="goBackAndReload();">Cancel</button>


        </div>
    </div>
    </body>

        <script src="assets/js/jquery.min.js"></script>
    <script src="assets/js/jquery.dropotron.min.js"></script>
    <script src="assets/js/jquery.scrolly.min.js"></script>
    <script src="assets/js/jquery.scrollex.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
            <script src="assets/js/sweetalert2/sweetalert2.min.js"></script>
    <script>


    // JavaScript to handle star rating and comment submission
document.addEventListener('DOMContentLoaded', () => {
    const stars = document.querySelectorAll('.star');
    let selectedRating = 0;

    // Handle star click for rating
    stars.forEach(star => {
        star.addEventListener('click', () => {
            selectedRating = star.getAttribute('data-value');
            resetStars();
            star.classList.add('active');
            let previousStar = star.previousElementSibling;
            while (previousStar) {
                previousStar.classList.add('active');
                previousStar = previousStar.previousElementSibling;
            }
        });
    });

    // Reset stars when a rating is clicked
    function resetStars() {
        stars.forEach(star => {
            star.classList.remove('active');
        });
    }

    // Handle comment submission
    const submitBtn = document.getElementById('submit-btn');
    const commentBox = document.getElementById('comment-box');
    const userComment = document.getElementById('user-comment');

    submitBtn.addEventListener('click', () => {
        const comment = commentBox.value.trim();

        if (selectedRating === 0) {
            Swal.fire({
                icon: 'error',
                title: 'Something Missing',
                text: 'Please choose a rate',
                confirmButtonColor: '#e74c3c'
            });
        } else if (comment === '') {
            Swal.fire({
                icon: 'error',
                title: 'Missing Comment',
                text: 'Please enter a comment.',
                confirmButtonColor: '#e74c3c'
            });
        } else {
            $.ajax({
                url: 'Comment.aspx/SubmitComment',
                type: 'POST',
                data: JSON.stringify({ rating: selectedRating, comment: comment }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "SUCCESS") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Comment Added',
                            confirmButtonText: 'OK',
                            confirmButtonColor: '#3498db'
                        }).then(() => {
                            window.location.href = document.referrer;
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: response.d || 'An error occurred while adding your comment.',
                            confirmButtonText: 'Try Again',
                            confirmButtonColor: '#e67e22'
                        });
                    }
                },
                error: function () {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Failed to add your comment. Please try again.',
                        confirmButtonText: 'OK',
                        confirmButtonColor: '#e67e22'
                    });
                }
            });
        }
    });


});
        function goBackAndReload() {
            // Check if there is a referrer (previous page)
            if (document.referrer) {
                // Navigate to the previous page and reload it

                window.location.href = document.referrer;
            } else {
                // Fallback if no referrer is available
                history.back();
            }
        }

    </script>
    </html>
