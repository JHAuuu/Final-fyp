<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="Recommendation.aspx.cs" Inherits="fyp.Recommendation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Recommendation Books
</asp:Content>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <meta charset="utf-8" />

    <link rel="stylesheet" href="assets/css/main.css" />
    <link rel="stylesheet" href="assets/css/modal.css" />
    <link rel="stylesheet" href="assets/css/recommendation.css" />
    <link rel="stylesheet" href="assets/css/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form id="form1" runat="server">
    <div class="container">
        <div class="row history-link">
                            <div class="history-link"><a href="Recommendation.aspx">Recomendation By User Preferences</a></div>
                            <div class="history-link"><a href="RecommendByUsers.aspx">Recommenadtion By Others User</a></div>
                                       <div class="history-link"><a href="RecommendForUser.aspx">Recommenadtion For User</a></div>
                        </div>
        <header>
            <h2><a href="#">Recommendation</a></h2>
        </header>

        <div class="filter-bar-container">
            <asp:Repeater ID="rptChoosenCat" runat="server" >
                        <ItemTemplate>
                             <%# string.IsNullOrEmpty(Eval("Active") as string) ? "" : $"<div class='filter-btn'>{Eval("CategoryName")}</div>" %>
                        </ItemTemplate>
                    </asp:Repeater>
            <div class="filter-btn add-btn" data-toggle="modal" data-target="#exampleModalCenter"><i class="fas fa-plus"></i>Add More..</div>
        </div>

        <!-- Book Items -->
        <div class="book-item-container">
            <!-- Repeat similar structure for each book item, or dynamically generate -->
            <asp:Panel ID="pnlBooks" runat="server">
            <asp:Repeater ID="rptBooks" runat="server" OnItemDataBound="rptBooks_ItemDataBound" OnPreRender="rptBooks_PreRender">
                <ItemTemplate>
                    <div class="book-item">
                <div class="book-details">
                    <div class="book-image">
                        <img src='<%# Eval("BookImage") != DBNull.Value ? Eval("BookImage"): "images/defaultCoverBook.png"  %> ' alt="Book Cover">
                    </div>
                   <div class="book-info">
                    <a href="BookDetail.aspx">
                        <h2 class="book-title"><%# Eval("BookTitle") %></h2>
                    </a>
                    <p class="book-detail"><span>Category: </span><%# Eval("CategoryNames") %></p>
                    <p class="book-detail"><%# !String.IsNullOrEmpty(Eval("BookSeries")?.ToString()) ? "<span>Series:</span> " + Eval("BookSeries") : "" %></p>
                    <p class="book-detail"><span>Author:</span> 
                        <asp:Repeater ID="rptAuthors" runat="server">
    <ItemTemplate>
        <span><%# Eval("AuthorName") %></span>
    </ItemTemplate>
</asp:Repeater>
                    </p>
                </div>
                    <div class="view-details-button-wrapper">
                        <a href="BookDetail.aspx?bookid=<%# Eval("BookId") %>" class="view-details-button">View Details</a>
                    </div>
                </div>
            </div>
                    </ItemTemplate>
            </asp:Repeater>
                </asp:Panel>
            <!-- Message for when no books are available -->
<div id="emptyMessage" runat="server" visible="false" class="empty-message">
    <p>No books in these category.</p>
</div>

        </div>

        <!-- Pagination -->
        <div class="pagination-container">
            <ul class="pagination-links">
                <li class="previous"><a href="#">Previous</a></li>
                <div class="pagination-numbers">
                    <ul class="pagination-numbers-list">
                    </ul>
                </div>
                <li class="next"><a href="#">Next</a></li>
            </ul>
        </div>
    </div>
    <div class="modal fade" id="exampleModalCenter" tabindex="-1" role="dialog"
        aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLongTitle">Choose your type</h5>

                </div>
                <div class="modal-body">
                    <asp:Repeater ID="rptCategory" runat="server" >
                        <ItemTemplate>
                            <div id="<%# Eval("CategoryId") %>"  onclick="toggleActive(this)"
                                class="filter-btn <%# Eval("Active") %>"><%# Eval("CategoryName") %></div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-category btn-close" data-dismiss="modal">Close</button>
                    <button type="button" class="btn-category btn-category-reset" onclick="Reset()">Reset</button>
                    <button type="button" class="btn-category btn-category-save" onclick="SaveChanges()">Save changes</button>
                </div>
            </div>
        </div>
    </div>
    </form>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptContent" runat="server">
    <!-- Scripts -->
    <script src="assets/js/jquery.min.js"></script>
    <script src="assets/js/jquery.dropotron.min.js"></script>
    <script src="assets/js/jquery.scrolly.min.js"></script>
    <script src="assets/js/jquery.scrollex.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
    <script src="assets/js/main.js"></script>
    <script src="assets/js/pagination.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script src="assets/js/sweetalert2/sweetalert2.min.js"></script>
    <script>
        function toggleActive(element) {
            // Toggle the 'active' class on the clicked element
            element.classList.toggle("active");
        }

        function SaveChanges() {
            console.log("clicked")
            var activeItems = [];
            $(".filter-btn.active").each(function () {
                activeItems.push($(this).attr("id")); // Assuming the div id is the CategoryId
            });
              $.ajax({
                  type: "POST",
                  url: "Recommendation.aspx/SaveChanges",
                  data: JSON.stringify({ categoryIds: activeItems }),
                  contentType: "application/json; charset=utf-8",
                  dataType: "json",
                  success: function (response) {
                      if (response.d == "SUCCESS") {
                          Swal.fire(
                              'Change Successfully!',
                              '',
                              'success'
                          ).then(function () {
                              window.location.href = "Recommendation.aspx";
                          });
                      } else {
                          Swal.fire({
                              icon: 'error',
                              title: 'Something Missing',
                              text: response.d
                          })
                      }
                  },
                  failure: function (response) {
                      Toast.fire({
                          icon: 'error',
                          title: 'Record Save Failed'
                      });
                  }
              });

        }

        function Reset() {
            console.log("clicked")
            $.ajax({
                type: "POST",
                url: "Recommendation.aspx/reset",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d == "SUCCESS") {
                        Swal.fire(
                            'Change Successfully!',
                            '',
                            'success'
                        ).then(function () {
                            window.location.href = "Recommendation.aspx";
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Something Missing',
                            text: response.d
                        })
                    }
                },
                failure: function (response) {
                    Toast.fire({
                        icon: 'error',
                        title: 'Removed Failed'
                    });
                }
            });

        }
    </script>
</asp:Content>