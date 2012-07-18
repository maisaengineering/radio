/*
 ______________________________________________________
/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
|          Another JavaScript from Uncle Jim           |
|                                                      |
|   Feel free to copy, use and change this script as   |
|        long as this part remains unchanged.          |
|                                                      |
|      Visit my website at http://www.jdstiles.com     |
|           for more scripts like this one             |
|                                                      |
|                     Created: 1996                    |
|              Last Updated: December, 2005            |
\______________________________________________________/
 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
function Graphics(canvas)
{
  this.canvas = canvas;
  this.cache = new Array;
  this.shapes = new Object;
  this.nObject = 0;

  // defaults
  this.penColor = "black";
  this.zIndex = 0;
}

Graphics.prototype.createPlotElement = function(x,y,w,h)
{
  // detect canvas
  if ( !this.oCanvas )
  {
    switch ( typeof(this.canvas) )
    {
      case "string":
        this.oCanvas = document.getElementById(this.canvas);
        break;
      case "object":
        this.oCanvas = this.canvas;
        break;
      default:
        this.oCanvas = document.body;
        break;
    }
  }

  // retrieve DIV
  var oDiv;
  if ( this.cache.length )
    oDiv = this.cache.pop();
  else
  {
    oDiv = document.createElement('div');
    this.oCanvas.appendChild(oDiv);

    oDiv.style.position = "absolute";
    oDiv.style.margin = "0px";
    oDiv.style.padding = "0px";
    oDiv.style.overflow = "hidden";
    oDiv.style.border = "0px";
  }

  // set attributes
  oDiv.style.zIndex = this.zIndex;
  oDiv.style.backgroundColor = this.penColor;

  oDiv.style.left = x;
  oDiv.style.top = y;
  oDiv.style.width = w + "px";
  oDiv.style.height = h + "px";

  oDiv.style.visibility = "visible";

  return oDiv;
}

Graphics.prototype.releasePlotElement = function(oDiv)
{
  oDiv.style.visibility = "hidden";
  this.cache.push(oDiv);
}

Graphics.prototype.addShape = function(shape)
{
  shape.oGraphics = this;
  shape.graphicsID = this.nObject;
  this.shapes[this.nObject] = shape;
  this.nObject++;
  shape.draw();
  return shape;
}

Graphics.prototype.removeShape = function(shape)
{
  if ( (shape instanceof Object) &&
    (shape.oGraphics == this) &&
    (this.shapes[shape.graphicsID] == shape) )
  {
    shape.undraw();
    this.shapes[shape.graphicsID] = undefined;
    shape.oGraphics = undefined;
  }
}
Graphics.prototype.clear = function()
{
  for ( var i in this.shapes )
    this.removeShape(this.shapes[i]);
}


//=============================================================================
// Point
Graphics.prototype.drawPoint = function(x,y)
{
  return this.addShape(new Point(x,y))
}

function Point(x,y)
{
  this.x = x;
  this.y = y;
}
Point.prototype.draw = function()
{
  this.oDiv = this.oGraphics.createPlotElement(this.x,this.y,1,1);
}
Point.prototype.undraw = function()
{
  this.oGraphics.releasePlotElement(this.oDiv);
  this.oDiv = undefined;
}

//=============================================================================
// Line
Graphics.prototype.drawLine = function(x1,y1,x2,y2)
{
  return this.addShape(new Line(x1,y1,x2,y2))
}

function Line(x1,y1,x2,y2)
{
  this.x1 = x1;
  this.y1 = y1;
  this.x2 = x2;
  this.y2 = y2;
}

Line.prototype.draw = function()
{
  this.plots = new Array;

  var dx = this.x2 - this.x1;
  var dy = this.y2 - this.y1;
  var x = this.x1;
  var y = this.y1;

  var n = Math.max(Math.abs(dx),Math.abs(dy));
  dx = dx / n;
  dy = dy / n;
  for ( i = 0; i <= n; i++ )
  {
    this.plots.push(this.oGraphics.createPlotElement(Math.round(x),Math.round(y),1,1));

    x += dx;
    y += dy;
  }
}
Line.prototype.undraw = function()
{
  while ( this.plots.length )
    this.oGraphics.releasePlotElement(this.plots.pop());
  this.plots = undefined;
}

//=============================================================================
// Circle
Graphics.prototype.drawCircle = function(x,y,r)
{
  return this.addShape(new Circle(x,y,r))
}

function Circle(x,y,r)
{
  this.x = x;
  this.y = y;
  this.radius = r;
}

Circle.prototype.draw = function()
{
  this.plots = new Array;

  var r2 = this.radius * this.radius;
  var x = 0;
  var y = this.radius;

  while ( x <= y )
  {
    this.plots.push(this.oGraphics.createPlotElement(Math.round(this.x + x), Math.round(this.y + y), 1, 1));
    this.plots.push(this.oGraphics.createPlotElement(Math.round(this.x - x), Math.round(this.y + y), 1, 1));
    this.plots.push(this.oGraphics.createPlotElement(Math.round(this.x + x), Math.round(this.y - y), 1, 1));
    this.plots.push(this.oGraphics.createPlotElement(Math.round(this.x - x), Math.round(this.y - y), 1, 1));
    this.plots.push(this.oGraphics.createPlotElement(Math.round(this.x + y), Math.round(this.y + x), 1, 1));
    this.plots.push(this.oGraphics.createPlotElement(Math.round(this.x + y), Math.round(this.y - x), 1, 1));
    this.plots.push(this.oGraphics.createPlotElement(Math.round(this.x - y), Math.round(this.y + x), 1, 1));
    this.plots.push(this.oGraphics.createPlotElement(Math.round(this.x - y), Math.round(this.y - x), 1, 1));

    x++;
    y = Math.round(Math.sqrt(r2 - x*x));
  }
}
Circle.prototype.undraw = Line.prototype.undraw;

//=============================================================================
// FillRectangle
Graphics.prototype.fillRectangle = function(x,y,w,h)
{
  return this.addShape(new FillRectangle(x,y,w,h))
}

function FillRectangle(x,y,w,h)
{
  this.x = x;
  this.y = y;
  this.w = w;
  this.h = h;
}

FillRectangle.prototype.draw = function()
{
  this.oDiv = this.oGraphics.createPlotElement(this.x,this.y,this.w,this.h);
}
FillRectangle.prototype.undraw = Point.prototype.undraw;

//=============================================================================

function drawProp()
{
  if ( p ) gr.removeShape(p);

  var x = Math.round(Math.sin(a) * 45);
  var y = Math.round(Math.cos(a) * 45);
  a -= Math.PI / 25;
  gr.penColor = "black";
  p = gr.drawLine(100 + x, 100 + y, 100 - x, 100 - y);
  window.setTimeout("drawProp();", 10);
}

function drawShapes()
{
  gr.penColor = "red";
  gr.drawLine(10,10,190,190);

  gr.penColor = "green";
  gr.drawLine(190,10,10,190);

  gr.penColor = "blue";
  c = gr.drawCircle(100,100,45);

  gr.zIndex = 1;
  gr.penColor = "lime";
  gr.fillRectangle(50,70,100,20);
  gr.zIndex = 0;

  drawProp();
}



<!--
/*
 _____________________________________
/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
| Another JavaScript from Uncle Jim   |
| Feel free to copy, use and change   |
| this script as long as this part    |
| remains unchanged. You can visit    |
| my website at http://jdstiles.com   |
| for more scripts like this one.     |
| Created: 1996 Updated: 2006         |
\_____________________________________/
 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Point.prototype.move = function(x,y)
{
  this.oDiv.style.left = x + "px";
  this.oDiv.style.top = y + "px";
}

Point.prototype.setSize = function(nSize)
{
  this.oDiv.style.width = nSize + "px";
  this.oDiv.style.height = nSize + "px";
}

function StarFieldSaver(settings)
{
  // default values
  this.speed = 50;
  this.nStars = 50;
  this.zIndex = 1000;

  // override with settings values
  if ( settings.speed ) this.speed = settings.speed;
  if ( settings.nStars ) this.nStars = settings.nStars;
  if ( settings.zIndex ) this.zIndex = settings.zIndex;
}
StarFieldSaver.prototype.init = function()
{
  this.oCanvas = document.createElement("div");
  document.body.appendChild(this.oCanvas);
  this.oCanvas.style.zIndex = this.zIndex;
  this.oCanvas.style.position = "absolute";

  red = Math.floor((Math.random()*255)+1);
  green = Math.floor((Math.random()*255)+1);
  blue =Math.floor((Math.random()*255)+1);
  opacity = Math.random();
  this.oCanvas.style.backgroundColor = "rgba(" + red + ", " + green + ", " + blue + ", 0)";

  this.g = new Graphics(this.oCanvas);

  red = Math.floor((Math.random()*255)+1);
  green = Math.floor((Math.random()*255)+1);
  blue =Math.floor((Math.random()*255)+1);
  opacity = Math.random();

  this.g.penColor = "rgba(" + red + ", " + green + ", " + blue + ", " + opacity + ")";

  this.aPoints = new Array();
}
StarFieldSaver.prototype.start = function()
{
  unbind_controls();
  show_controls();
  if ( this.bActive ) return;
  this.bActive = true;

  if ( !this.oCanvas ) this.init();
  this.oCanvas.style.visibility = "visible";
  this.tick();
}
StarFieldSaver.prototype.stop = function()
{
  rebind_controls();
  hide_controls_fast();
  if ( !this.bActive ) return;

  window.clearTimeout(this.timerID);
  this.oCanvas.style.visibility = "hidden";

  for ( var i in this.aPoints )
  {
    this.aPoints[i].undraw();
  }
  this.aPoints = new Array();

  this.bActive = false;
}
StarFieldSaver.prototype.tick = function()
{
  this.oCanvas.style.left = document.body.scrollLeft + "px";
  this.oCanvas.style.top = document.body.scrollTop + "px";
  this.oCanvas.style.width = document.body.clientWidth + "px";
  this.oCanvas.style.height = document.body.clientHeight + "px";


  this.width = document.body.clientWidth;
  this.height = document.body.clientHeight;

  var cx = this.width / 2;
  var cy = this.height / 2;
  for ( var i in this.aPoints )
  {
    var p = this.aPoints[i];
    var dx = p.x - cx;
    var dy = p.y - cy;

    // move point outwards
    p.x += dx / 50;
    p.y += dy / 50;
    if ( (p.x < 0) || (p.x > this.width - Math.ceil(p.n/50)) || (p.y < 0) || (p.y > this.height - Math.ceil(p.n/50)) )
    {
      p.x = Math.random() * this.width;
      p.y = Math.random() * this.height;
      p.n = 0;
    }
    p.move(Math.floor(p.x),Math.floor(p.y));

    // resize as they get closer
    p.setSize(Math.ceil(p.n++ / 50) + 25);
  }

  while ( this.aPoints.length < this.nStars )
  {
    red = Math.floor((Math.random()*255)+1);
    green = Math.floor((Math.random()*255)+1);
    blue =Math.floor((Math.random()*255)+1);
    opacity = Math.random();

    this.g.penColor = "rgba(" + red + ", " + green + ", " + blue + ", 0.4)";
    var x = 1 * this.width;
    var y = 1 * this.height;
    var p = this.g.drawPoint(Math.floor(x), Math.floor(y));
    p.setSize(1);
    p.x = x;
    p.y = y;
    p.n = 0;
    this.aPoints.push(p);
  }

  var pThis = this;
  var f = function(){pThis.tick();}
  this.timerID = window.setTimeout(f,this.speed);
}

function ScreenSaver(settings)
{
  this.settings = settings;

  this.nTimeout = this.settings.timeout;

  document.body.screenSaver = this;

  // link in to body events
  document.body.onmousemove = ScreenSaver.prototype.onevent;
  document.body.onmousedown = ScreenSaver.prototype.onevent;
  document.body.onkeydown = ScreenSaver.prototype.onevent;
  document.body.onkeypress = ScreenSaver.prototype.onevent;

  var pThis = this;
  var f = function(){pThis.timeout();}
  this.timerID = window.setTimeout(f, this.nTimeout);
}
ScreenSaver.prototype.timeout = function()
{
  if ( !this.saver )
  {
    this.saver = this.settings.create();
  }
  this.saver.start();
}
ScreenSaver.prototype.signal = function()
{
  if ( this.saver )
  {
    this.saver.stop();
  }

  window.clearTimeout(this.timerID);

  var pThis = this;
  var f = function(){pThis.timeout();}
  this.timerID = window.setTimeout(f, this.nTimeout);
}

ScreenSaver.prototype.onevent = function(e)
{
  if(e.keyCode == 13){
    this.screenSaver.signal();
  }
}


var saver;
function initScreenSaver()
{
  //blort;
  //300000 ms = 5 min
  //speed = Math.floor((Math.random()*)+1);
  stars = 500;
  //saver = new ScreenSaver({timeout:900000,speed:150,nStars:stars,zIndex: 10000,create:function(){return new StarFieldSaver(this);}});
  saver = new ScreenSaver({timeout:900000,speed:40,nStars:stars,zIndex: 10000,create:function(){return new StarFieldSaver(this);}});
}
