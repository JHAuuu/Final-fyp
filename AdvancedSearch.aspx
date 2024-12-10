<%@ Page Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="AdvancedSearch.aspx.cs" Inherits="fyp.AdvancedSearch" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Search Book
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="assets/css/main.css" />
    <link rel="stylesheet" href="assets/css/bookSearch.css" />
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* General Styles */
        .search-container {
            max-width: 800px;
            margin: 20px auto;
        }

        h1 {
            text-align: left;
            font-size: 24px;
            margin-bottom: 20px;
        }

        .search-form, .date-filters {
            display: flex;
            flex-direction: column;
        }

        .input-row {
            gap: 5px;
            margin-bottom: 5px;
        }

        .title-row, .input-row {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr 1fr 40px; /* Adjusted for '×' button */
            text-align: center; /* Centers text horizontally */
        }

            .title-row label {
                font-size: 14px;
                font-weight: bold;
                margin: 0;
            }

            .input-row select, .input-row input {
                padding: 8px;
                font-size: 14px;
                border: 1px solid #ccc;
                border-radius: 5px;
                box-sizing: border-box; /* Ensures consistent box dimensions */
            }

        .hidden-column {
            visibility: hidden; /* Keeps the space but hides content */
            opacity: 0; /* Makes it fully transparent */
            transition: visibility 0s, opacity 0.3s ease;
        }

            .hidden-column.show {
                visibility: visible; /* Reveals content */
                opacity: 1; /* Makes it fully visible */
            }

        .search-button-row {
            margin-top: 10px;
            text-align: right;
        }

            .search-button-row button {
                background-color: #2b74a9;
                color: white;
                padding: 10px 20px;
                font-size: 16px;
                border: none;
                border-radius: 5px;
                cursor: pointer;
            }

                .search-button-row button:hover {
                    background-color: #1a5b7a;
                }

        .date-filters {
            padding: 5px;
            margin-top: 20px;
            box-shadow: 0px 2px 10px rgba(0, 0, 0, 0.1);
        }
            /* Date Filters Section */
            .date-filters .title-row {
                display: grid;
                grid-template-columns: 1fr 1fr 1fr; /* Three equal columns */
                gap: 10px;
                text-align: center;
            }

            .date-filters .input-row {
                display: grid;
                grid-template-columns: 1fr 1fr 1fr; /* Three equal columns */
                gap: 10px;
                align-items: center;
            }

            .date-filters select, .date-filters input {
                padding: 8px;
                font-size: 14px;
                border: 1px solid #ccc;
                border-radius: 5px;
                box-sizing: border-box; /* Ensures consistent box dimensions */
            }

        .reset-button {
            margin-top: 10px;
            text-align: right;
        }

            .reset-button button {
                background-color: #e0e0e0;
                color: black;
                border: none;
                border-radius: 5px;
                cursor: pointer;
            }

                .reset-button button:hover {
                    background-color: #d3d3d3;
                }

        .date-filters .search-button-row {
            margin-top: 10px;
            text-align: right;
        }

            .date-filters .search-button-row button {
                background-color: #2b74a9;
                color: white;
                padding: 10px 20px;
                font-size: 16px;
                border: none;
                border-radius: 5px;
                cursor: pointer;
            }

                .date-filters .search-button-row button:hover {
                    background-color: #1a5b7a;
                }
        /* Remove button style for each search field */
        .remove-btn {
            padding: 8px;
        }

            .remove-btn:hover {
                background-color: darkred;
            }
        /* Add New Search Field Button */
        #addNewField {
            cursor: pointer;
        }

            #addNewField:hover {
                background-color: #45a049;
            }
        /* Disabled Input Styling */
        input:disabled {
            background-color: #e9ecef;
            cursor: not-allowed;
        }

        .book-item {
            min-width: 1200px;
        }
        .seachBtn{
            width: 75px;
        }
    </style>
    <form class="search-form" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="search-container">
            <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <h1 runat="server" id="lblRecordCount">Search 0 records for:</h1>
                </ContentTemplate>
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                </Triggers>
            </asp:UpdatePanel>
            <!-- Title Row -->
            <div class="title-row" style="width: 100%;">
                <label for="hiddenColumn"></label>

                <label for="searchTerm">Search Term</label>
            </div>

            <!-- Search Fields Container -->
            <div id="searchFieldsContainer">
                <!-- Input Row -->
                <div class="input-row" style="width: 100%;">
                    <div class="hidden-column">
                        <input type="text" placeholder="Hidden content here" />
                    </div>
                    <select name="searchField">
                        <option value="allFields">All fields</option>
                        <option value="title">Title</option>
                        <option value="author">Author</option>
                        <option value="category">Category</option>
                        <option value="isbn">ISBN</option>
                        <option value="year">Publish Year</option>
                    </select>
                    <select name="contains">
                        <option value="allWords">All words</option>
                        <option value="anyWords">Any words</option>
                    </select>
                    <input type="text" name="searchTerm" placeholder="Enter search term" />
                    <button type="button" class="remove-btn" style="visibility: hidden;">×</button>
                </div>
            </div>
        <!-- Add New Search Field Button -->
        <div style="text-align: right; margin-top: 10px;">
            <button type="button" id="addNewField">+ Add New Search Field</button>
        </div>
        <!-- Date Filters Section -->
        <div class="date-filters">
            <!-- Title Row -->
            <div class="title-row">
                <label for="timePeriod">Create Time Period</label>
                <label for="fromDate">From Date</label>
                <label for="toDate">To Date</label>
            </div>

            <!-- Input Row -->
            <div class="input-row">
                <select id="timePeriod" name="timePeriod">
                    <option value="allTime">All time</option>
                    <option value="lastYear">Last year</option>
                    <option value="lastMonth">Last month</option>
                </select>
                <input type="date" id="fromDate" name="fromDate" />
                <input type="date" id="toDate" name="toDate" />
            </div>

            <!-- Reset and Search Button Row -->
            <div class="reset-button">
                <button type="button" id="btnReset">Reset</button>
                <asp:Button ID="btnSearch" runat="server" Text="Search" Cssclass="seachBtn" OnClick="btnSearch_Click" />
            </div>
        </div>
        <!-- Search Tips -->
        <small style="font-size: .9286rem;">Search Tips :: 
               
            <asp:HyperLink ID="HyperLink1" runat="server" Style="border: none; color: #2b74a9;" NavigateUrl="~/BookSearch.aspx">Simple Search</asp:HyperLink>
        </small>
        </div>
   
        <!-- Books Display Section -->
        <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <div class="book-item-container">
                    <asp:Panel ID="pnlBooks" runat="server">
                        <asp:Repeater ID="rptBooks" runat="server">
                            <ItemTemplate>
                                <div class="book-item">
                                    <div class="book-details">
                                        <div class="book-image">
                                            <asp:Image ID="imageBook" runat="server"
                                                ImageUrl='<%# Eval("BookImage") != DBNull.Value ? "data:image/png;base64," + Convert.ToBase64String((byte[])Eval("BookImage")) : "images/defaultCoverBook.png" %>'
                                                AlternateText="Book Cover" />
                                        </div>
                                        <div class="book-info">
                                            <a href="BookDetail.aspx">
                                                <h2 class="book-title"><%# Eval("BookTitle") %></h2>
                                            </a>
                                            <p class="book-detail">
                                                <span>Category: </span><%# Eval("CategoryNames") %>
                                            </p>
                                            <p class="book-detail">
                                                <%# !String.IsNullOrEmpty(Eval("BookSeries")?.ToString()) ? "<span>Series:</span> " + Eval("BookSeries") : "" %>
                                            </p>
                                            <p class="book-detail">
                                                <span>Author: </span>
                                                        <span><%# Eval("AuthorNames") %></span>
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
                        <p>No books here.</p>
                    </div>
                </div>
            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
            </Triggers>
        </asp:UpdatePanel>
    </form>
    <!-- Pagination Section -->
    <div class="pagination-container">
        <ul class="pagination-links">
            <li class="previous"><a href="#">Previous</a></li>
            <div class="pagination-numbers">
                <ul class="pagination-numbers-list">
                    <!-- Pagination numbers will be dynamically generated -->
                </ul>
            </div>
            <li class="next"><a href="#">Next</a></li>
        </ul>
    </div>
    <script>
        // Function to handle adding new search fields
        document.getElementById('addNewField').addEventListener('click', function () {
            // Get the container for input rows
            const container = document.getElementById('searchFieldsContainer');

            // Create a new input row
            const newRow = document.createElement('div');
            newRow.className = 'input-row';
            newRow.style.width = '100%';

            // Add hidden column
            const hiddenColumn = document.createElement('div');
            hiddenColumn.className = 'hidden-column';
            const hiddenInput = document.createElement('input');
            hiddenInput.type = 'text';
            hiddenInput.placeholder = 'Hidden content here';
            hiddenColumn.appendChild(hiddenInput);

            // Add searchIn dropdown
            const searchInSelect = document.createElement('select');
            searchInSelect.name = 'searchField'; // Ensure name attribute for form submission
            searchInSelect.innerHTML = `
                <option value="allFields">All fields</option>
                <option value="title">Title</option>
                <option value="author">Author</option>
                <option value="category">Category</option>
                <option value="isbn">ISBN</option>
                <option value="year">Publish Year</option>
            `;

            // Add contains dropdown
            const containsSelect = document.createElement('select');
            containsSelect.name = 'contains'; // Ensure name attribute for form submission
            containsSelect.innerHTML = `
                <option value="allWords">All words</option>
                <option value="anyWords">Any words</option>
            `;

            // Add search term input
            const searchTermInput = document.createElement('input');
            searchTermInput.type = 'text';
            searchTermInput.name = 'searchTerm'; // Ensure name attribute for form submission
            searchTermInput.placeholder = 'Enter search term';

            // Add remove button
            const removeBtn = document.createElement('button');
            removeBtn.type = 'button';
            removeBtn.className = 'remove-btn';
            removeBtn.textContent = '×';
            removeBtn.addEventListener('click', function () {
                container.removeChild(newRow);
            });

            // Append elements to the new row
            newRow.appendChild(hiddenColumn);
            newRow.appendChild(searchInSelect);
            newRow.appendChild(containsSelect);
            newRow.appendChild(searchTermInput);
            newRow.appendChild(removeBtn);

            // Append the new row to the container
            container.appendChild(newRow);
        });

        // Function to handle removal of the first row's remove button if needed
        const firstRowRemoveBtn = document.querySelector('.input-row .remove-btn');
        if (firstRowRemoveBtn) {
            firstRowRemoveBtn.style.display = 'none'; // Hide remove button for the first row
        }

        // Function to toggle date inputs based on timePeriod selection
        function toggleDateInputs() {
            var timePeriodSelect = document.getElementById('timePeriod');
            var selectedValue = timePeriodSelect.value;
            var fromDateInput = document.getElementById('fromDate');
            var toDateInput = document.getElementById('toDate');

            if (selectedValue === 'lastYear' || selectedValue === 'lastMonth') {
                fromDateInput.disabled = true;
                toDateInput.disabled = true;

                // Optionally, clear the date inputs when disabled
                fromDateInput.value = '';
                toDateInput.value = '';
            } else {
                fromDateInput.disabled = false;
                toDateInput.disabled = false;
            }
        }

        // Attach event listener to timePeriod select
        document.getElementById('timePeriod').addEventListener('change', toggleDateInputs);

        // Initialize the state on page load
        window.onload = function () {
            toggleDateInputs();
        };

        // Function to handle Reset button
        document.getElementById('btnReset').addEventListener('click', function () {
            // Reset all search fields to default values
            const container = document.getElementById('searchFieldsContainer');
            container.innerHTML = `
                <div class="input-row" style="width: 100%;">
                    <div class="hidden-column">
                        <input type="text" placeholder="Hidden content here" />
                    </div>
                    <select name="searchField">
                        <option value="allFields">All fields</option>
                        <option value="title">Title</option>
                        <option value="author">Author</option>
                        <option value="category">Category</option>
                        <option value="isbn">ISBN</option>
                        <option value="year">Publish Year</option>
                    </select>
                    <select name="contains">
                        <option value="allWords">All words</option>
                        <option value="anyWords">Any words</option>
                    </select>
                    <input type="text" name="searchTerm" placeholder="Enter search term" />
                    <button type="button" class="remove-btn" style="visibility: hidden;">×</button>
                </div>
            `;

            // Reset the timePeriod select to 'allTime'
            var timePeriodSelect = document.getElementById('timePeriod');
            timePeriodSelect.value = 'allTime';
            toggleDateInputs();
        });
    </script>
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
    <script src="assets/js/pagination.js"></script>
</asp:Content>
