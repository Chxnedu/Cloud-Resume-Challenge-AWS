fetch('https://x2ufdd9eb5.execute-api.us-east-1.amazonaws.com/update_count')
.then(data => { return data.json(); })
.then(count => { 
    console.log(count.N); 
    document.getElementById('counter').
    innerHTML= 'This page has been visited ' + count.N + ' times';
});

