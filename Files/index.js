fetch('https://jl0b5q4gk9.execute-api.us-east-1.amazonaws.com')
.then(data => { return data.json(); })
.then(count => { 
    console.log(count.N); 
    document.getElementById('counter').
    innerHTML= count.N + ' People have viewed this resume';
});

