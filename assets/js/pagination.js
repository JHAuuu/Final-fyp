// Wrap code in a closure to avoid duplicate declarations if loaded multiple times
(() => {
    document.addEventListener('DOMContentLoaded', function () {
        const bookItems = document.querySelectorAll('.book-item');
        const itemsPerPage = 3;
        const paginationContainer = document.querySelector('.pagination-container');

        if (!paginationContainer) {
            console.error('Pagination container not found');
            return; // Exit if paginationContainer is missing
        }

        const previousButton = paginationContainer.querySelector('.pagination-links .previous');
        const nextButton = paginationContainer.querySelector('.pagination-links .next');
        const paginationNumbersList = paginationContainer.querySelector('.pagination-numbers-list');

        if (!previousButton || !nextButton || !paginationNumbersList) {
            console.error('Pagination elements (previous, next, numbers) not found');
            return; // Exit if any key elements are missing
        }

        let currentPage = 1;
        let totalPages = Math.ceil(bookItems.length / itemsPerPage);

        function createPagination() {
            totalPages = Math.ceil(bookItems.length / itemsPerPage);
            paginationNumbersList.innerHTML = ''; // Clear existing pagination

            for (let i = 1; i <= totalPages; i++) {
                const pageLink = document.createElement('a');
                pageLink.textContent = i;
                pageLink.href = `#page-${i}`;
                pageLink.classList.add('pagination-link'); // Optional for styling or identification

                if (i === currentPage) {
                    pageLink.classList.add('active');
                }

                const listItem = document.createElement('li');
                listItem.appendChild(pageLink);

                pageLink.addEventListener('click', (event) => {
                    event.preventDefault();
                    const pageNumber = parseInt(event.target.textContent);
                    showPage(pageNumber);
                });

                paginationNumbersList.appendChild(listItem);
            }

            // Add click events for previous and next buttons
            previousButton.addEventListener('click', () => showPage(currentPage - 1));
            nextButton.addEventListener('click', () => showPage(currentPage + 1));
        }

        function showPage(pageNumber) {
            if (pageNumber < 1 || pageNumber > totalPages) {
                return;
            }

            // Hide all book items
            bookItems.forEach((item) => item.style.display = 'none');

            // Show the book items for the current page
            const startIndex = (pageNumber - 1) * itemsPerPage;
            const endIndex = Math.min(startIndex + itemsPerPage, bookItems.length);
            for (let i = startIndex; i < endIndex; i++) {
                bookItems[i].style.display = 'block';
            }

            // Update active page link
            currentPage = pageNumber;
            paginationNumbersList.querySelectorAll('a').forEach((link) => link.classList.remove('active'));
            const activePageLink = paginationNumbersList.querySelector(`a[href="#page-${pageNumber}"]`);
            if (activePageLink) {
                activePageLink.classList.add('active');
            }

            // Update previous and next button states
            previousButton.classList.toggle('disabled', currentPage === 1);
            nextButton.classList.toggle('disabled', currentPage === totalPages);

            console.log(`Showing page ${pageNumber} of ${totalPages}`);
        }

        // Initialize pagination
        createPagination();
        showPage(1); // Show the first page
    });
})();
