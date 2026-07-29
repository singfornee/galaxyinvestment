/* Galaxy Investment Limited — shared behaviour */
(function () {
  // Current year in footer
  var y = document.getElementById('year');
  if (y) y.textContent = '© ' + new Date().getFullYear() + ' Galaxy Investment Limited. All rights reserved.';

  // Sticky nav shadow
  var hdr = document.getElementById('hdr');
  if (hdr) {
    var onScroll = function () { hdr.classList.toggle('scrolled', window.scrollY > 8); };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  // Contact form (no backend — hand off to the visitor's mail client)
  var form = document.getElementById('enquiry');
  if (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var get = function (id) { var el = document.getElementById(id); return el ? el.value : ''; };
      var subject = encodeURIComponent('New enquiry — ' + get('interest'));
      var body = encodeURIComponent(
        'Name: ' + get('name') + '\n' +
        'Email: ' + get('email') + '\n' +
        'Company: ' + get('company') + '\n' +
        'Interest: ' + get('interest') + '\n\n' +
        get('message')
      );
      window.location.href = 'mailto:hello@galaxyinvestment.hk?subject=' + subject + '&body=' + body;
      var done = document.getElementById('form-done');
      if (done) { form.style.display = 'none'; done.style.display = 'flex'; }
    });
  }

  // Starfield
  var canvas = document.getElementById('stars');
  if (!canvas) return;
  var ctx = canvas.getContext('2d');
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var stars = [], w, h, dpr = Math.min(window.devicePixelRatio || 1, 2);

  function resize() {
    w = canvas.width = innerWidth * dpr;
    h = canvas.height = innerHeight * dpr;
    canvas.style.width = innerWidth + 'px';
    canvas.style.height = innerHeight + 'px';
    var count = Math.min(160, Math.floor((innerWidth * innerHeight) / 9000));
    stars = [];
    for (var i = 0; i < count; i++) {
      stars.push({
        x: Math.random() * w,
        y: Math.random() * h,
        r: (Math.random() * 1.3 + 0.3) * dpr,
        a: Math.random() * 0.6 + 0.2,
        tw: Math.random() * 0.02 + 0.004,
        ph: Math.random() * Math.PI * 2,
        gold: Math.random() < 0.14
      });
    }
  }
  function draw(t) {
    ctx.clearRect(0, 0, w, h);
    for (var i = 0; i < stars.length; i++) {
      var s = stars[i];
      var op = reduce ? s.a : s.a * (0.55 + 0.45 * Math.sin(t * s.tw + s.ph));
      ctx.beginPath();
      ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
      ctx.fillStyle = s.gold ? 'rgba(233,190,92,' + op + ')' : 'rgba(255,255,255,' + op + ')';
      ctx.fill();
    }
    if (!reduce) requestAnimationFrame(draw);
  }
  resize();
  window.addEventListener('resize', resize);
  if (reduce) draw(0); else requestAnimationFrame(draw);
})();
