<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="LoanList.aspx.cs" Inherits="fyp.LoanList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Books Loaning
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="assets/css/main.css" />
    <link rel="stylesheet" href="assets/css/loanList.css" />
    <link rel="stylesheet" href="assets/css/fontawesome-all.min.css" />
        <link rel="stylesheet" href="assets/css/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Label ID="lblErrorMessage" runat="server" Text="" CssClass="error-message" Visible="false"></asp:Label>
    <br/>
    <br/>
    <div class="row gtr-200">
        <div class="col-4 col-12-mobile" id="sidebar">
            <hr class="first" />
                <header>
                    <h3><a href="#">Late Returned Book Fine</a></h3>
                </header>
                <div class="row gtr-50">
                    <asp:Repeater runat="server" ID="rptPunishment">
                        <HeaderTemplate>
                            <section>
                        </HeaderTemplate>
                        <ItemTemplate>
                           
                            <div class="col-12" style="border-radius: 10px; border: 1px solid #ccc; padding: 10px;">
                                <h4><%# Eval("BookTitle") %></h4>
                                <p>
                                    ISBN : <%# Eval("ISBN") %>
                                </p>
                                <p>
                                    <%# Eval("LatestReturn") %>
                                </p>
                            </div>
                               
                        </ItemTemplate>
                        <FooterTemplate>
                            
                        <footer>

                            <form runat="server" id="form1">
                                <p>Total Fine: <%= totalFine %></p>
                            <asp:Button ID="btnPaymentStart" runat="server" Text="Pay Now" OnClick="btnPaymentStart_Click" />
                                </form>
                        </footer>
                            </section>
                        </FooterTemplate>

                    </asp:Repeater>
                    
                    <asp:Panel runat="server" ID="punishmentEmptyMessage" Visible="false">
                        <div class="col-8 no-data-message">
                            <p>No fine at the moment.</p>
                        </div>
                    </asp:Panel>


                    <asp:Repeater runat="server" ID="rptNotReturn">
                        <HeaderTemplate>
                   
                    <h3><a href="#">Please Return these books</a></h3>
       
                            <section>
                        </HeaderTemplate>
                        <ItemTemplate>
                           
                            <div class="col-12" style="border-radius: 10px; border: 1px solid #ccc; padding: 10px;">
                                <img src="<%# Eval("BookCopyImage") != DBNull.Value ? Eval("BookCopyImage") : "images/defaultCoverBook.png" %>" width="100" alt="Books" />
                                <h4><%# Eval("BookTitle") %></h4>
                                <p>
                                    ISBN : <%# Eval("ISBN") %>
                                </p>
                                 <p>
                                    <%# Eval("LatestReturn") %>
                                </p>
                            </div>
                               
                        </ItemTemplate>
                        <FooterTemplate>
                            </section>
                        </FooterTemplate>

                    </asp:Repeater>

                </div>
        </div>

        <!--Body Content-->
        <div class="col-8 col-12-mobile imp-mobile" id="content">
            <article id="main">
                <section>
                    <header>
                        <h2>Trust Credit</h2>
                    </header>
                    <div class="center-container">
                        
                        <div class="speedometer">
                            <div class="needle" id="needle" style="--score: <%= userTrustValue %>"></div>
                        </div>
                        <span><%= userTrustValue %> Credit</span>
                        <div class="trust-level-message">
                            <span><%= userTrustLevel %></span>
                            
                        </div>
                    </div>
                </section>
                <section>
                    <div class="rows">
                    <header>
                        <h2>Currently Loaning..</h2>
                        
                    </header>
                        <button class="add-loan" onclick="loanBook(event)"><i class="fas fa-plus"></i> Borrow more books</button>
                        </div>
                    <div class="history-container">

                        <!--Body Content-->
                        <asp:Repeater runat="server" ID="rptLoan">
                            <ItemTemplate>
                                <div class="history-item">
                                    <img src="<%# Eval("BookCopyImage") != DBNull.Value ? Eval("BookCopyImage") : "images/defaultCoverBook.png" %>" width="150" alt="" />
                                    <div class="time"><%# (DateTime.Parse(Eval("EndDate").ToString()) - DateTime.Parse(Eval("StartDate").ToString())).Days + " days left" %></div>
                                    <div class="details">
                                        <div class="book-title"><%# Eval("BookTitle")%></div>
                                        <div class="description">
                                            <span>Date: </span> <%# string.Format("{0:yyyy-MM-dd} to {1:yyyy-MM-dd}", Eval("StartDate"), Eval("EndDate")) %><br />
                                            <span>ISBN: </span><%# Eval("ISBN")%>
                                        </div>
                                    </div>
                                    <div class="view-detail">
                                        <button style="width: 125px; padding: 5px 10px; margin-right: 20px;" onclick="window.location.href = 'LoanDetail.aspx?LoanId=<%# Eval("LoanId") %>';">View Detail</button>
                                        <%-- Add the Extend Date button conditionally --%>
                 <%# ShowExtendDateButton(Eval("StartDate"), Eval("EndDate"), Eval("LoanId")) %>
                                    </div>
                                </div>
                            </ItemTemplate>


                        </asp:Repeater>
                        <asp:Panel runat="server" ID="loanEmptyMessage" Visible="false">
                            <div class="no-data-message">
                                <p>No punishments available at the moment.</p>
                            </div>
                        </asp:Panel>

                    </div>
                </section>
            </article>
        </div>
    </div>
    
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
    <!-- Scripts -->
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
        function loanBook(event) {

            // AJAX to check trust level
            $.ajax({
                url: 'LoanList.aspx/checkTrustLevel',
                type: 'POST',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "SUCCESS") {
                        window.location.href = "LoanBook.aspx";
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

        function extendDate(loanId) {

            // AJAX to check trust level
            $.ajax({
                url: 'LoanList.aspx/ExtendDate',
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
    </script>
    </asp:Content>
