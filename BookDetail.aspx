<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="BookDetail.aspx.cs" Inherits="fyp.BookDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Book Detail
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="assets/css/main.css" />
    <link rel="stylesheet" href="assets/css/modal.css" />
    <link rel="stylesheet" href="assets/css/bookDetail.css" />
    <link rel="stylesheet" href="assets/css/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
         <div>
            <!-- Image Back Button -->
    <img src="images/back-button.png" alt="Back" onclick="goBackAndReload();" style="cursor: pointer; position: relative; z-index: 100;" class="back-button" />
        </div>
    <div class="row gtr-200">
        <div class="col-8 col-12-mobile" id="content">
            <article id="main">
                <header>
                    <h2><a href="#">
                        <asp:Label runat="server" ID="lblTitle"></asp:Label></a></h2>
                </header>
                <div class="row">
                    <div class="col-md-4">
                        <a href="#" class="image featured">
                            <asp:Image runat="server" ID="imgBook"  Width="250" Height="350"/>
                        </a>
                    </div>
                    <div class="col-md-4">
                        <div class="details">
                            <h1>Details</h1>
                            <h5>Category:<asp:Label runat="server" ID="lblCategory"> </asp:Label>
                            </h5>
                            <asp:Panel runat="server" ID="pnlSeries">
                                <h5>Series:
                                   
                                    <asp:Label runat="server" ID="lblSeries"></asp:Label></h5>
                            </asp:Panel>
                            <h5>Book Author:
                               
                                <asp:Label runat="server" ID="lblAuthor"></asp:Label></h5>
                            <p>
                                <asp:Label runat="server" ID="lblDesc"></asp:Label>
                            </p>


                        </div>
                       <% if (userid !=  0) { %>
    <div class="fav-btn <%= isFavorite ? " active" : "" %>" onclick="removeFav(this)">
        <i class="fa fa-heart"></i>
    </div>
<% } %>



                    </div>
                </div>
                <section>
                    <div class="comment-section">

                        <div class="comment-box">
                            <div class="star-rating" >
                                                                <span class="star active" data-star="1" style="padding-right:10px;" onclick="filterComments('all')">
            <span style="color: black;">All</span>&#9733; 
        </span>
                                <span class="star active" data-star="1" style="padding-right:10px;" onclick="filterComments(1)">
            <span style="color: black;">1</span>&#9733; 
            <span style="color: black;">(<%= GetStarCount(1) %>)</span>
        </span>
        <span class="star active" data-star="2" style="padding-right:10px;" onclick="filterComments(2)">
            <span style="color: black;">2</span>&#9733; 
            <span style="color: black;">(<%= GetStarCount(2) %>)</span>
        </span>
        <span class="star active" data-star="3" style="padding-right:10px;" onclick="filterComments(3)">
            <span style="color: black;">3</span>&#9733; 
            <span style="color: black;">(<%= GetStarCount(3) %>)</span>
        </span>
        <span class="star active" data-star="4" style="padding-right:10px;" onclick="filterComments(4)">
            <span style="color: black;">4</span>&#9733; 
            <span style="color: black;">(<%= GetStarCount(4) %>)</span>
        </span>
        <span class="star active" data-star="5" style="padding-right:10px;" onclick="filterComments(5)">
            <span style="color: black;">5</span>&#9733; 
            <span style="color: black;">(<%= GetStarCount(5) %>)</span>
        </span>
                            </div>
                        </div>
                        <asp:Panel runat="server" ID="pnlComment" Visible="false">
                            <div class="col-8 no-data-message">
                                <p>No Comment at the moment.</p>
                            </div>
                        </asp:Panel>
                        <div id="commentContainer">
                        <asp:Repeater runat="server" ID="rptComment">
                            <ItemTemplate>
                                <div class="comment" data-comment-id='<%# Eval("RateDate") + "_" + Eval("PatronId") %>'>
                                    <div class="star-rating">
                                        <!-- Dynamically add the active class based on RateStarts -->
                                        <span class="star <%# Convert.ToInt32(Eval("RateStarts").ToString()) >= 1 ? "active" : "" %>" data-value="1">&#9733;</span>
                                        <span class="star <%# Convert.ToInt32(Eval("RateStarts").ToString()) >= 2 ? "active" : "" %>" data-value="2">&#9733;</span>
                                        <span class="star <%# Convert.ToInt32(Eval("RateStarts").ToString()) >= 3 ? "active" : "" %>" data-value="3">&#9733;</span>
                                        <span class="star <%# Convert.ToInt32(Eval("RateStarts").ToString()) >= 4 ? "active" : "" %>" data-value="4">&#9733;</span>
                                        <span class="star <%# Convert.ToInt32(Eval("RateStarts").ToString()) >= 5 ? "active" : "" %>" data-value="5">&#9733;</span>


                                    </div>
                                    <div class="comment-details">
                                        <div class="username">@<%# Eval("UserName") %></div>
                                        <div class="time"><%# Eval("RateDate", "{0:dd MMM yyyy}") %></div>
                                    </div>
                                    <p class="comment-text">
                                        <%# Eval("RateComment") %>
                                    </p>
                                    <asp:PlaceHolder runat="server" Visible='<%# Eval("PatronId").ToString() == CurrentUserPatronId.ToString() %>'>
                                        <div class="user-cmt cmt">
                                            <div class="edit-cmt cmt"><a href="Comment.aspx?bookId=<%= bookid.ToString() %>&date=<%# Eval("RateDate") %>">Edit</a></div>
                                            <div class="dlt-cmt cmt">
                                                <a onclick="deleteComment('<%= bookid.ToString() %>', '<%# Eval("PatronId") %>', '<%# Eval("RateDate") %>')">Delete</a>
                                            </div>
                                        </div>
                                    </asp:PlaceHolder>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                            </div>


                    </div>

                </section>
            </article>
        </div>
        <div class="col-4 col-12-mobile" id="sidebar">
            <section>
                <header>
                    <h3><a href="#">More others related books</a></h3>
                </header>
                <div class="row gtr-50">
                    <asp:Panel runat="server" ID="pnlRelatedBook" Visible="false">
                        <div class="col-8 no-data-message">
                            <p>No Related Book at the moment.</p>
                        </div>
                    </asp:Panel>
                    <asp:Repeater runat="server" ID="rptRelatedBook">
                        <ItemTemplate>
                            <div class="col-8">
                                <a href="BookDetail.aspx?bookid=<%# Eval("BookId") %>" class="image fit">
                                    <img src="<%# Eval("BookImage")!=DBNull.Value ? fyp.ImageHandler.GetImage((byte[])Eval("BookImage")): "images/defaultCoverBook.png" %>" alt="" width="50" height="250" /></a>
                                <h4><%# Eval("BookTitle") %></h4>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </section>
        </div>
    </div>

    <div class="modal fade" id="exampleModalCenter" tabindex="-1" role="dialog"
        aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLongTitle">Do you which to add to another groups?</h5>

                </div>
                <div class="modal-body">

                    <div class="container-list">
                        <div class="task__list">
                            <asp:Repeater runat="server" ID="rptGroup">
                                <ItemTemplate>
                                    <label class="task">
                                        <input class="task__check" type="checkbox" id="<%# Eval("FavGrpId") %>" />
                                        <div class="task__field task--row">
                                            <%# Eval("FavGrpName") %>
                                            <button class="task__important"><i class="fa fa-check" aria-hidden="true"></i></button>
                                        </div>
                                    </label>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                    </div>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-category btn-close" data-dismiss="modal" onclick="">Cancel</button>
                    <button type="button" class="btn-category btn-category-save" data-dismiss="modal" onclick="AddDefaultly()">No, Thanks</button>
                    <button type="button" class="btn-category btn-category-save" data-dismiss="modal" onclick="AddToGroup()">Add</button>
                </div>
            </div>
        </div>
    </div>


</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
    <script src="assets/js/jquery.dropotron.min.js"></script>
    <script src="assets/js/jquery.scrolly.min.js"></script>
    <script src="assets/js/jquery.scrollex.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
    <script src="assets/js/main.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script src="assets/js/sweetalert2/sweetalert2.min.js"></script>
    <script>
        function removeFav(element) {
            if (element.classList.contains("active")) {
                Swal.fire({
                    title: 'Delete Group',
                    html: `<p>Do you want to Remove from favourite?`,
                    icon: 'warning',
                    showConfirmButton: false,
                    showCancelButton: true,
                    showDenyButton: true,
                    denyButtonText: 'Remove from all favourites',
                    cancelButtonText: 'Cancel',
                    denyButtonColor: '#3498db',
                    cancelButtonColor: '#95a5a6',
                    buttonsStyling: true
                }).then((result) => {
                    if (result.isDenied) {
                        // AJAX to remove from all favourites
                        $.ajax({
                            url: 'BookDetail.aspx/RemoveFromAll',
                            type: 'POST',
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                if (response.d === "SUCCESS") {
                                    Swal.fire({ icon: 'success', title: 'Removed from all', confirmButtonText: 'OK' });
                                    element.classList.toggle("active");
                                } else {
                                    Swal.fire({ icon: 'error', title: 'Error', text: response.d, confirmButtonText: 'Try again' });
                                }
                            }
                        });
                    }
                });
            } else {
                $('#exampleModalCenter').modal('show');

            }
        }


        function AddToGroup() {


            const selectedGroups = [];
            $('#exampleModalCenter').find('.task__check:checked').each(function () {
                selectedGroups.push(this.id); // Collect the id of each checked checkbox
            });

            if (selectedGroups.length === 0) {
                Swal.fire({
                    icon: 'warning',
                    title: 'No Groups Selected',
                    text: 'Please select at least one group to add the book.',
                    confirmButtonText: 'OK',
                    confirmButtonColor: '#3498db'
                });
                return;
            }

            $.ajax({
                url: 'BookDetail.aspx/AddToGroups',
                type: 'POST',
                data: JSON.stringify({ groupIds: selectedGroups }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "SUCCESS") {
                        // Show a success message and close the modal
                        Swal.fire({
                            icon: 'success',
                            title: 'Added',
                            confirmButtonText: 'OK',
                            confirmButtonColor: '#3498db'
                        });
                        $('#exampleModalCenter').modal('hide');
                        $('.fav-btn').toggleClass("active");
                    } else {
                        // Show an error message if the server response indicates failure
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: response.d,
                            confirmButtonText: 'Try again',
                            confirmButtonColor: '#e67e22'
                        });
                    }
                },
                error: function () {
                    // Show an error message if the AJAX call fails
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Failed to add to the default group. Please try again.',
                        confirmButtonText: 'OK',
                        confirmButtonColor: '#e67e22'
                    });
                }
            });
        }

        function deleteComment(bookId, patronId, date) {
            $.ajax({
                url: 'BookDetail.aspx/DeleteComment',
                type: 'POST',
                data: JSON.stringify({ bookId: bookId, patronId: patronId, date: date }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "SUCCESS") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Comment Deleted',
                            confirmButtonText: 'OK',
                            confirmButtonColor: '#3498db'
                        }).then(() => {
                            // Combine RateDate and PatronId to match the 'data-comment-id' format
                            var commentId = date + "_" + patronId;

                            // Find the comment container using the combined 'data-comment-id' and remove it
                            $('.comment[data-comment-id="' + commentId + '"]').remove();
                        });;
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: response.d || 'An error occurred while delete your comment.',
                            confirmButtonText: 'Try Again',
                            confirmButtonColor: '#e67e22'
                        });
                    }
                },
                error: function () {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Failed to delete your comment. Please try again.',
                        confirmButtonText: 'OK',
                        confirmButtonColor: '#e67e22'
                    });
                }
            });
        }


        function AddDefaultly() {


            // Perform an AJAX call to add the favorite item to the default group
            $.ajax({
                url: 'BookDetail.aspx/AddToDefaultGroup',
                type: 'POST',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "SUCCESS") {
                        // Show a success message and close the modal
                        Swal.fire({
                            icon: 'success',
                            title: 'Added',
                            confirmButtonText: 'OK',
                            confirmButtonColor: '#3498db'
                        });
                        $('#exampleModalCenter').modal('hide');
                        $('.fav-btn').toggleClass("active");
                    } else {
                        // Show an error message if the server response indicates failure
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: response.d,
                            confirmButtonText: 'Try again',
                            confirmButtonColor: '#e67e22'
                        });
                    }
                },
                error: function () {
                    // Show an error message if the AJAX call fails
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Failed to add to the default group. Please try again.',
                        confirmButtonText: 'OK',
                        confirmButtonColor: '#e67e22'
                    });
                }
            });
        }



        function filterComments(starRating) {

            console.log(`Filtering comments for ${starRating}-star ratings`);

            // Example AJAX logic for fetching filtered comments
            $.ajax({
                url: 'BookDetail.aspx/GetCommentsByStarRating',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ starRating: starRating }),
                success: function (response) {
                    const commentsHtml = response.d; // Assuming server returns the HTML content
                    $('#commentContainer').html(commentsHtml);
                },
                error: function (error) {
                    console.error('Error fetching comments:', error);
                }
            });
        }

    </script>
</asp:Content>
