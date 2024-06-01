const searchInput = document.getElementById("search-input");
const searchResultsDiv = document.getElementById("search-results");
//const memberIdInput = document.getElementById("member-id");
const editionInput = document.getElementById("edition");
const registerButton = document.getElementById("register-button");

searchInput.addEventListener("input", (event) => {
    const searchTerm = event.target.value;

    const xhr = new XMLHttpRequest();
    xhr.open("GET", `get_community_members?name_part=${searchTerm}`, true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.send();

    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            const response = JSON.parse(xhr.responseText);
            searchResultsDiv.innerHTML = "";
            response.forEach((member) => {
                const memberDiv = document.createElement("div");
                memberDiv.textContent = `${member.imie} ${member.nazwisko}`;
                memberDiv.addEventListener("click", () => {
                    memberIdInput.value = member.id_czlonka;
                });
                searchResultsDiv.appendChild(memberDiv);
            });
        } else {
            searchResultsDiv.textContent = `Wystąpił błąd: ${xhr.statusText}`;
        }
    };
});

registerButton.addEventListener("click", (event) => {
    event.preventDefault();
    const memberId = memberIdInput.value;
    const edition = editionInput.value;

    const xhr = new XMLHttpRequest();
    xhr.open("POST", "register_volunteer", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.send(`member_id=${memberId}&edition=${edition}`);

    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            const response = xhr.responseText;
            alert(`Zarejestrowano wolontariusza o ID członka ${response.memberId} w edycji ${response.edition}.`);
        } else {
            alert(`Wystąpił błąd: ${xhr.statusText}`);
        }
    };
});