fetch('https://qzomn91yyl.execute-api.us-east-1.amazonaws.com/update_count')
.then(data => { return data.json(); })
.then(count => { 
    console.log(count.N); 
    document.getElementById('counter').
    innerHTML= count.N + ' People have viewed this resume';
});

