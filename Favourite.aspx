<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="Favourite.aspx.cs" Inherits="fyp.Favourite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Favourites
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="assets/css/main.css" />
    <link rel="stylesheet" href="assets/css/modal.css" />
    <link rel="stylesheet" href="assets/css/favourite.css" />
    <link rel="stylesheet" href="assets/css/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
     <div>
            <!-- Image Back Button -->
            <img src="images/back-button.png" alt="Back" onclick="goBackAndReload();" class="back-button" />
        </div>
    <div class="container" style="padding-bottom: 10%;">
        <header>
            <h2><a href="#">Stored Books</a></h2>
        </header>
        <!--Body Content-->
        <div class="product-container">
            <asp:Repeater runat="server" ID="rptBooks">
    <ItemTemplate>
        <div class="card">
            <a href="BookDetail.aspx?bookid=<%# Eval("BookId") %>">
                <div class="title"><%# Eval("BookTitle") %></div>
                <div class="image">
                    <img src="<%# Eval("BookImage") != DBNull.Value ? Eval("BookImage"): "images/defaultCoverBook.png"  %>" alt="HI" />
                </div>
            </a>
            <div class="fav-btn fav-id<%#Eval("BookId") %> active" id="<%# Eval("FavId")  %>" onclick="removeFav('<%# Eval("BookId") %>','<%# Request.QueryString["groupId"] %>',this)">
                <i class="fa fa-heart"></i>
            </div>

        </div>
    </ItemTemplate>
    </asp:Repeater>


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
                    <input type="hidden" id="hiddenBookId" />
                    <div class="container-list">
                        <div class="task__list">
                            <asp:Repeater runat="server" ID="rptGroup">
                                <ItemTemplate>
                                    <label class="task">
                                        <input class="task__check" type="checkbox" id="<%# Eval("FavGrpId") %>"/>
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
    <script src="assets/js/jquery.min.js"></script>
    <script src="assets/js/jquery.dropotron.min.js"></script>
    <script src="assets/js/jquery.scrolly.min.js"></script>
    <script src="assets/js/jquery.scrollex.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
    <script src="assets/js/SSmain.js"></script>

    <script src="assets/js/sweetalert2/sweetalert2.min.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script>
        function removeFav(bookId, groupId, element) {
            if (element.classList.contains("active")) {
                Swal.fire({
                    title: 'Delete Group',
                    html: `<p>Do you want to Remove from<strong>this group</strong> or <strong>from all favourites</strong> as well?</p>`,
                    icon: 'warning',
                    showCancelButton: true,
                    showDenyButton: true,
                    confirmButtonText: groupId ? 'Remove from this Group' : '',
                    denyButtonText: 'Remove from all favourites',
                    cancelButtonText: 'Cancel',
                    confirmButtonColor: '#e74c3c',
                    denyButtonColor: '#3498db',
                    cancelButtonColor: '#95a5a6',
                    showConfirmButton: !!groupId,
                    buttonsStyling: true
                }).then((result) => {
                    if (result.isConfirmed) {
                        // AJAX to remove from group
                        $.ajax({
                            url: 'Favourite.aspx/RemoveFromGroup',
                            type: 'POST',
                            data: JSON.stringify({ groupId: groupId, bookId: bookId }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                if (response.d === "SUCCESS") {
                                    Swal.fire({ icon: 'success', title: 'Removed from group!', confirmButtonText: 'OK' });
                                    element.classList.toggle("active");
                                    element.closest(".card").remove();
                                } else {
                                    Swal.fire({ icon: 'error', title: 'Error', text: response.d, confirmButtonText: 'Try again' });
                                }
                            }
                        });
                    } else if (result.isDenied) {
                        // AJAX to remove from all favourites
                        $.ajax({
                            url: 'Favourite.aspx/RemoveFromAll',
                            type: 'POST',
                            data: JSON.stringify({ bookId: bookId  }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                if (response.d === "SUCCESS") {
                                    Swal.fire({ icon: 'success', title: 'Removed from all', confirmButtonText: 'OK' });
                                    element.classList.toggle("active");
                                    element.closest(".card").remove();
                                } else {
                                    Swal.fire({ icon: 'error', title: 'Error', text: response.d, confirmButtonText: 'Try again' });
                                }
                            }
                        });
                    }
                });
            } else {
                $('#exampleModalCenter').modal('show');
                $('#exampleModalCenter').find('#hiddenBookId').val(bookId);
            }
        }


        function AddToGroup() {
            const bookId = $('#exampleModalCenter').find('#hiddenBookId').val();

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
                url: 'Favourite.aspx/AddToGroups',
                type: 'POST',
                data: JSON.stringify({ bookId: bookId, groupIds: selectedGroups }),
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
                        $('.fav-id' + bookId).toggleClass("active");
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

        function AddDefaultly() {
            const bookId = $('#exampleModalCenter').find('#hiddenBookId').val();

            // Perform an AJAX call to add the favorite item to the default group
            $.ajax({
                url: 'Favourite.aspx/AddToDefaultGroup',
                type: 'POST',
                data: '{bookId: "' + bookId +
                    ' "}',
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
                        $('.fav-id' + bookId).toggleClass("active");
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

    </script>
</asp:Content>
