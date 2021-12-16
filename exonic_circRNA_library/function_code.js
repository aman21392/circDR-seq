function recursive(i,array) {
    if(i==exons.length) {
        if(array.length==0) return;
        var t="";
        var s="";
        for(var j in array) {
            t+=exons[array[j]].name+"|";
            s+=exons[array[j]].seq;
            }
        print(">"+t+"\n"+s);
        return;
        }

    var copy = array.slice();
    recursive(i+1,copy);
    copy = array.slice();
    copy.push(i);
    recursive(i+1,copy);
    }


var array=[];
recursive(0,array);

