function keyAllowed(e, validchars)
{
     var key='', keychar='';
     key = getKeyCode(e);
     if (key == null) return true;
     keychar = String.fromCharCode(key);
     keychar = keychar.toLowerCase();
     validchars = validchars.toLowerCase();
     if (validchars.indexOf(keychar) != -1)
        return true;
     if ( key==null || key==0 || key==8 || key==9 || key==13 || key==27 )
        return true;
     return false;
}
function removeChars(str)
{
    var val = str.replace(/[^\d]/g, "");
    if(val.charAt(0) == "0"){
        val = val.substring(1,val.length)
    }
    return val
}

function getKeyCode(e)
{
     if (window.event)
        return window.event.keyCode;
     else if (e)
        return e.which;
     else
        return null;
}

function onlycharacter(field)
{
    //var regx = /^[a-zA-Z]*$/;
    //var regx = /^[a-z]+$/;

    //var v = document.getElementById("text1").value;
    //var v = field.value
    var v = field.value

    if(!(/^[a-zA-Z]*$/).test(v))
    {
        //alert(v + ' contains invalid characters');
      return null;
    }
    else
    {
      return true;
    }

    

    //var regx = /[:alpha:]+/;
    //if (!regx.test(field.value))
    //{ 
    //  alert('wrong');  
    //  return false;
    //}
    //else
    //{
     // alert('hii');
      //field.value = field.value;
      //return true;

    //}
    
}

function isNumber(field)
{
    var re = /^[0-9-'.'-',']*$/;
    if (!re.test(field.value))
    {
	field.value = field.value.replace(/[^0-9-'.'-',']/g,"");
    }
    field.value = Comma(field.value);
}
function Comma(number)
{
    
    //var number = document.getElementById(id).value;
    number = removeCommas(number);
    var tnumber = number;
    var roundedNumber = roundNumber(number,0);
    number = roundedNumber;
    if (roundedNumber > tnumber)
    {
        var rnumber = roundedNumber - tnumber
    }
    else
    {
        var rnumber = tnumber - roundedNumber
    }
    number = '' + number;
    if (number.length > 3)
    {
        var mod = number.length % 3;
        var output = (mod > 0 ? (number.substring(0,mod)) : '');
        for (i=0 ; i < Math.floor(number.length / 3); i++)
        {
            if ((mod == 0) && (i == 0))
                output += number.substring(mod+ 3 * i, mod + 3 * i + 3);
            else
                output+= ',' + number.substring(mod + 3 * i, mod + 3 * i + 3);
        }

        if((rnumber > 0) && (tnumber< 999))
        {
            output = output + "." + rnumber;
        }
        //checkDecimals(id,output);
        //document.getElementById(id).value = output;
        return (output);
    }
    else
    {
        if (number != "")
        {
            var output = parseFloat(removeCommas(number));
            //checkDecimals(id,output);
            if(output == 0)
                output = ""

            return output;
        }
        else
        {
            return ""
        }
    }
}
function checkDecimals(fieldName, fieldValue)
{
    decallowed = 0;  // how many decimals are allowed?

    if (isNaN(fieldValue) || fieldValue == "" || parseInt(fieldValue)==0)
    {
        document.getElementById(fieldName).value="";
        document.getElementById(fieldName).select();
        document.getElementById(fieldName).focus();
    }
    else
    {
        strvalue=''+fieldValue;
        if (strvalue.indexOf('.') == -1) strvalue += ".";
        dectext = strvalue.substring(strvalue.indexOf('.')+1, strvalue.length);

        if (dectext.length > decallowed)
        {
            var strLen = strvalue.length;
            myStr = strvalue.slice(0,strLen-1);
            document.getElementById(fieldName).value = myStr;
        }
   }
}

function roundNumber(num, dec)
{
    var result = Math.round(num*Math.pow(10,dec))/Math.pow(10,dec);
    return result;
}

function removeCommas(aNum)
{
    aNum=aNum.replace(/,/g,""); //remove any commas
    aNum=aNum.replace(/\s/g,""); //remove any spaces
    return aNum;
}

function charCount(id,Div,num)
{
    var str=document.getElementById(id).value;
    if((num-str.length)<0)
    {
        document.getElementById(id).value=str.substring(0,num);str=document.getElementById(id).value;
    }
    var left_char=num-str.length
    document.getElementById(Div).innerHTML=left_char;
}


window.onload = function()
{
    // initialization
    // ...
}


/* common functionality */


function showHide( id )
{
    var e = document.getElementById( id );
    if( e ) {
        state = ( getStyle( e, 'display' ) == 'none' ) ? 'block' : 'none';
        showHideHelper( e, state );
    }
}


function showHideAll()
{
    var state = null;
    var divs = document.getElementsByTagName( 'div' );
    for( i = 0; i < divs.length; i++ ) {
        if( divs[i].className != 'show-hide' ) continue;
        if( !state ) state = ( getStyle( divs[i], 'display' ) == 'none' ) ? 'block' : 'none';
        showHideHelper( divs[i], state );
    }
}


function showHideHelper( e, state )
{
    setStyle( e, 'display', state );
    if( state == 'block' ) {
        setCookie( 'showHide_' + e.id, state );
    } else {
//        setCookie( 'showHide_' + e.id, state );
        delCookie( 'showHide_' + e.id );
    }
}


function setStyle( e, name, value )
{
    e.style[name] = value;
}


function getStyle( e, name )
{
    return e.style[name];
}


/* Cookies ================================================================== */


function setCookie( name, value, days )
{
    if( !days ) days = 7;

    var date = new Date();
    date.setTime( date.getTime() + ( days * 24 * 60 * 60 * 1000 ) );
    var expires = "; expires=" + date.toGMTString();

    document.cookie = name + "=" + value + expires + "; path=/";
}


function getCookie( cookieName )
{
    var cookieString = document.cookie;
    var startLoc = cookieString.indexOf( cookieName );
    if( startLoc == -1 ) return null;
    var sepLoc = cookieString.indexOf( "=", startLoc );
    var endLoc = cookieString.indexOf( ";", startLoc );
    if( endLoc == -1 ) endLoc = cookieString.length;
    return( cookieString.substring( sepLoc+1, endLoc ) );
}

function delCookie( name )
{
    var date = new Date();
    document.cookie = name + "=1;expires=" + date.toGMTString() + ";" + ";";
}

function getCookies()
{
    var cookies = {};
    var nameValueList = document.cookie.split(';');
    var item = 0;
    for( item = 0; item < nameValueList.length; item++ )
    {
        var nameValue = nameValueList[item].split('=');
        cookies[ nameValue[0] ] = nameValue[1];
    }
    return cookies;
}


