// const animateButton = document.getElementById('animate-button');

// animateButton.addEventListener('click', () => {
//     animateButton.classList.add('animate');
// });



let photo = document.getElementById("logo");
    let main = document.getElementById("container");
    let buttons = document.getElementById('container__buttons');
    let footer = document.getElementById('footer');
    let content = document.getElementById('content');
    let body = document.getElementById('body');
    
    
    function contrast() {
        if (main.classList.contains("highcontrast")) {
            photo.classList.remove("photo_highcontrast");
            main.classList.remove("highcontrast");
            buttons.classList.remove("buttons_highcontrast");
            content.classList.remove("highcontrast");
            footer.classList.remove("highcontrast");
            body.classList.remove("highcontrast");
    
        } else {
            photo.classList.toggle("photo_highcontrast");
            main.classList.toggle("highcontrast");
            buttons.classList.toggle("buttons_highcontrast");
            footer.classList.toggle("highcontrast");
            content.classList.toggle("highcontrast");
            body.classList.toggle("highcontrast");
        }
    }
    
    
    
    function changeSizeB() {
        if (main.classList.contains("sizebig")) {
            main.classList.remove("sizebig");
    
        } else {
            main.classList.remove("sizesmall");
            main.classList.toggle("sizebig");
    
        }
    }
    
    function changeSizeS() {
        if (main.classList.contains('sizesmall')) {
    
            main.classList.remove("sizesmall");
    
        } else {
            main.classList.remove("sizebig");
            main.classList.toggle("sizesmall");
        }
    }
    
    function contrastPlease() {
        contrast();
    }
    const navToggle = document.querySelector('.nav-toggle');
const navLinks = document.querySelector('.nav-links');

navToggle.addEventListener('click', () => {
  navLinks.classList.toggle('active');
});