<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="LoanDetail.aspx.cs" Inherits="fyp.LoanDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Loan Details
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="assets/css/loanDetail.css" />
            <link rel="stylesheet" href="assets/css/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
                    <div>
            <!-- Image Back Button -->
            <img src="images/back-button.png" alt="Back" onclick="history.back(); return false;" class="back-button" />
        </div>
    <!--Body Content-->
    <header>
        <h2><a href="#">Loan Details</a></h2>
    </header>
    <div style="display: flex; justify-content: center;">
        <asp:Image ID="imgBook" runat="server" Height="150px" Width="150px" />
    </div>
    <section>
        <header>
            <h3>Book Title:
                <asp:Label ID="lblBookTitle" runat="server" Text="N/A"></asp:Label></h3>
            <h5>ISBN: </h5>
            <asp:Label ID="lblISBN" runat="server" Text="N/A"></asp:Label>
        </header>
        <div class="info-container">
            <div class="info-item">
                <h5>Publish Date:</h5>
                <asp:Label ID="lblPubDate" runat="server" Text="N/A"></asp:Label>
            </div>
            <div class="info-item">
                <h5>Publish Owner:</h5>
                <asp:Label ID="lblOwner" runat="server" Text="N/A"></asp:Label>
            </div>
            <div class="info-item">
                <h5>Status:</h5>
                <asp:Label ID="lblStatus" runat="server" Text="N/A"></asp:Label>
            </div>

            <div class="info-item">
                <h5>Start Date:</h5>
                <asp:Label ID="lblStartDate" runat="server" Text="N/A"></asp:Label>
            </div>

            <div class="info-item">
                <h5>Date you should return:</h5>
                <asp:Label ID="lblEndDate" runat="server" Text="N/A"></asp:Label>
            </div>

            <div class="info-item">
                <h5>Book Returned on:</h5>
                <asp:Label ID="lblLatestReturn" runat="server" Text="N/A"></asp:Label>
            </div>
            <div class="info-item">
            <asp:Panel ID="pnlDaysLeftToReturn" runat="server" Visible="false">
                
                    <h5>Days left to return:</h5>
                    <asp:Label ID="lblDaysLeftToReturn" runat="server" Text="N/A"></asp:Label>
                
            </asp:Panel>
                </div>
            <div class="info-item">
            </div>


            <div class="info-item">
                <h5>Do you recommended this book?:</h5>
                <div class="recommend-section">
                    <button id="btnRecommendUp"
                        class="btn-recommend <%= recommended == "up" ? "active" : "" %>">
                        <i class="fa fa-arrow-up"></i>
                    </button>
                    <button id="btnRecommendDown"
                        class="btn-recommend <%= recommended == "down" ? "active" : "" %>">
                        <i class="fa fa-arrow-down"></i>
                    </button>
                </div>
            </div>

            <div class="info-item">
            </div>

            <div class="info-item">
            </div>

            <div class="info-item">
             <asp:Panel ID="pnlComment" runat="server" Visible="false">
                
                    <h5>Do you want to comment?</h5>
                    <button  onclick="window.location.href = 'Comment.aspx?bookId=<%= GetBookId() %>&loanId=<%= loanId.ToString() %>';">Comment</button>
                
            </asp:Panel>
                </div>

            <div class="info-item">
            </div>

            <div class="info-item">
            </div>

            <div class="info-item">
            <asp:Panel ID="pnlExtendDate" runat="server" Visible="false">
                
                    <h5>Do you want to Extend for one more week?</h5>
                    <button onclick="extendDate('<%= loanId.ToString() %>')">Extend Now</button>
                
            </asp:Panel>
                </div>

        </div>
    </section>

</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
    <script src="assets/js/jquery.min.js"></script>
    <script src="assets/js/jquery.dropotron.min.js"></script>
    <script src="assets/js/jquery.scrolly.min.js"></script>
    <script src="assets/js/jquery.scrollex.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
                <script src="assets/js/sweetalert2/sweetalert2.min.js"></script>
    <script>

        function extendDate(loanId) {

            // AJAX to check trust level
            $.ajax({
                url: 'LoanDetail.aspx/ExtendDate',
                type: 'POST',
                data: JSON.stringify({ loanId: loanId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "SUCCESS") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Date Extended',
                            text: 'You have extended successfully',
                            confirmButtonText: 'OK'
                        }).then(() => {
                            // Reload the page after the success message is closed
                            location.reload();
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Loan Failed',
                            text: response.d,
                            confirmButtonText: 'OK'
                        });
                    }
                }
            });
        }


        document.addEventListener("DOMContentLoaded", function () {
            const btnUp = document.getElementById("btnRecommendUp");
            const btnDown = document.getElementById("btnRecommendDown");

            // Event listener for Upvote button
            btnUp.addEventListener("click", function () {
                console.log("Up");
                if (!btnUp.classList.contains("active")) {
                    btnUp.classList.add("active");  // Add active to Upvote
                    btnDown.classList.remove("active");  // Remove active from Downvote
                } else {
                    btnUp.classList.remove("active");  // Reset to none
                }

                $.ajax({
                    url: 'LoanDetail.aspx/bookRecommended',
                    type: 'POST',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json"
                });
            });

            // Event listener for Downvote button
            btnDown.addEventListener("click", function () {
                console.log("Down");
                if (!btnDown.classList.contains("active")) {
                    btnDown.classList.add("active");  // Add active to Downvote
                    btnUp.classList.remove("active");  // Remove active from Upvote
                } else {
                    btnDown.classList.remove("active");  // Reset to none
                }
                $.ajax({
                    url: 'LoanDetail.aspx/bookNotRecommended',
                    type: 'POST',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json"
                });
            });
        });
    </script>
</asp:Content>
