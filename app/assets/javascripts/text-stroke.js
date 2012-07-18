function processTextStroke(selector){
  var v=getElementsBySelector(selector);
  for(i=0;i < v.length;i++){
    processElement(v[i]);
  }
}

function processElement(v){
  var content=v.innerHTML;
  for (j=1;j<=8;j++){
    var d=document.createElement("span");
    d.className = "stroke"+j;
    d.innerHTML = content;
    v.appendChild(d);
  }
  v.removeChild(v.firstChild);
  var dd=document.createElement("span");
  dd.className = "rawtext";
  dd.innerHTML = content;
  v.appendChild(dd);
}

function NiftyCheck(){
  if(!document.getElementById || !document.createElement)
    return(false);
  var b=navigator.userAgent.toLowerCase();
  if(b.indexOf("msie 5")>0 && b.indexOf("opera")==-1)
    return(false);
  return(true);
}

function getElementsBySelector(selector){
  var i;
  var s=[];
  var selid="";
  var selclass="";
  var tag=selector;
  var objlist=[];
  if(selector.indexOf(" ")>0){  //descendant selector like "tag#id tag"
    s=selector.split(" ");
    var fs=s[0].split("#");
    if(fs.length==1) return(objlist);
    return(document.getElementById(fs[1]).getElementsByTagName(s[1]));
  }
  if(selector.indexOf("#")>0){ //id selector like "tag#id"
    s=selector.split("#");
    tag=s[0];
    selid=s[1];
  }
  if(selid!=""){
    objlist.push(document.getElementById(selid));
    return(objlist);
  }
  if(selector.indexOf(".")>0){  //class selector like "tag.class"
    s=selector.split(".");
    tag=s[0];
    selclass=s[1];
  }
  var v=document.getElementsByTagName(tag);  // tag selector like "tag"
  if(selclass=="")
    return(v);
  for(i=0;i < v.length;i++){
    if(v[i].className==selclass){
      objlist.push(v[i]);
    }
  }
  return(objlist);
}