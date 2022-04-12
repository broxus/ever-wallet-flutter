String getDuckDuckGoSearchLink(String query) => 'https://duckduckgo.com/?q=$query';

String getErrorPage({
  required Uri url,
  required String message,
}) =>
    '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <style>
        html {
            background-color: #060C32;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        div {
            margin: 16px;
            color: white;
            font-size: 1em;
            line-height: 1.6em;
        }
    </style>
</head>
<body>
    <div>
        <h1>Website not available</h1>
        <p>Could not load web pages at <strong>$url</strong> because:</p>
        <p>$message</p>
    </div>
</body>
''';
