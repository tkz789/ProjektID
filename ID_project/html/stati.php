<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edycje Statystyki</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
    <h1>Statystyki Edycji</h1>
    <button id="getStatistics">Pobierz Statystyki</button>
    <div id="statistics"></div>

    <script>
        function getStatistics() {
            $.ajax({
                url: 'get_statistics.php',
                type: 'GET',
                dataType: 'json',
                success: function (data) {
                    const table = $('<table></table>');
                    const tableHead = $('<thead></thead>');
                    const tableBody = $('<tbody></tbody>');

                    const tableHeadRow = $('<tr><th>ID</th><th>Społeczność</th><th>Uczestników</th></tr>');
                    tableHead.append(tableHeadRow);

                    data.forEach(community => {
                        const tableBodyRow = $(`<tr><td>${community.id_spolecznosci}</td><td>${community.nazwa_spolecznosci}</td><td>${community.count_participants}</td></tr>`);
                        tableBody.append(tableBodyRow);
                    });

                    table.append(tableHead);
                    table.append(tableBody);
                    $('#statistics').append(table);
                },
                error: function (error) {
                    console.error(error);
                    $('#statistics').text('Wystąpił błąd podczas pobierania statystyk.');
                }
            });
        }

        $('#getStatistics').on('click', getStatistics);
    </script>
</body>
</html>
<?php
header('Content-Type: application/json');

$db = pg_connect("host=localhost dbname=your_database user=your_user password=your_password");

if (!$db) {
    http_response_code(500);
    echo json_encode(['error' => 'Nieudane połączenie z bazą danych.']);
    exit;
}

$result = pg_query($db, 'SELECT id_spolecznosci, nazwa_spolecznosci, (SELECT count(*) FROM get_participants(id_edycji)) as count_participants FROM spolocnosci');

if (!$result) {
    http_response_code(500);
    echo json_encode(['error' => 'Nieudane pobieranie statystyk.']);
    exit;
}

$data = pg_fetch_all($result);

echo json_encode($data);
?>