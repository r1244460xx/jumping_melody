
import processing.serial.*;
import gifAnimation.*;
import ddf.minim.*;
import java.util.Queue;
import java.util.LinkedList;


Serial port;
Minim minim;  //music obj
AudioPlayer player = null; //music player obj

class Cursor{
    private PImage img;
    public int x;
    public int y;
    public int ans;
    public int time;
    public int type;
    
    Cursor(int k, int t){
        x = 1600;
        time = t;         
        type = k;
        if(type == 1){
            ans = int(random(5));
            y = 700;         
            switch(ans){
                case 0:
                    img = loadImage("up.png");
                    break;
                    
                case 1:
                    img = loadImage("left.png");
                    break;
                    
                case 2:
                    img = loadImage("down.png");
                    break;
                
                case 3:
                    img = loadImage("right.png");
                    break;
                
                case 4:
                    img = loadImage("middle.png");
                    break;
            }
        }
            
        else{
            ans = int(random(4));
            y = 400;
            switch(ans){
                case 0:
                    img = loadImage("pointer1.png");
                    break;
                    
                case 1:
                    img = loadImage("pointer2.png");
                    break; 
                    
                case 2:
                    img = loadImage("pointer3.png");
                    break;
                
                case 3:
                    img = loadImage("pointer4.png");
                    break; 
            }
        }     
             
    }
    
    void draw(){      //draw map as the current position
        image(img, x, y, 200, 200);
    }
    
    void move(){
        x -= 40;  //not smooth, but fast
    }
} 

class Evaluate{
    private int counter;
    private int eval;
    
    Evaluate(int e){
        eval = e;
        counter = 20;
    }
    
    void draw(){
        if(counter > 0){
            PImage eval_img;
            switch(eval){
            case 1:
                eval_img = loadImage("bad.png");
                image(eval_img, 1400, 100, 400, 200);
                break;
                
            case 2:
                eval_img = loadImage("normal.png");
                image(eval_img, 1400, 100, 400, 200);
                break;
                
            case 3:
                eval_img = loadImage("excellent.png");
                image(eval_img, 1400, 100, 400, 200);
                break;
                
            default:
                break;
            }
            counter--;
        }
    }   
}

boolean is_standby = true;

PImage backimage, logo, upper_bar, lower_bar, score_icon, check_point;

int index = 0;
int prev = 0;

int curr_cursor = 0;

Evaluate evaluation;

Cursor[] map = new Cursor[20];  //change to beatmap file in the future

LinkedList<Cursor> queue = new LinkedList<Cursor>();

void img_init(){
    try{
        imageMode(CENTER);
        backimage = loadImage("background.png"); //Make a beautiful background-image
        logo = loadImage("logo.png");  //Make a beautiful logo image  
        upper_bar = loadImage("upper_bar.png");
        lower_bar = loadImage("lower_bar.png");
        score_icon = loadImage("score_icon.png");
        check_point = loadImage("check_point.png");
    }
    catch(Exception e){
        println("Please check your png file integration");
        stop();
    }
}

void port_init(){
    try{
        port = new Serial(this, Serial.list()[0], 115200);
    }
    catch(Exception e){
        println("Please check your serial connection");
        stop();  
    }
}

void draw_background(){
    if(is_standby){  //standby page        
        background(backimage);                   
        image(logo, 800, 450);        
        String any_key = "Please key space to start";
        fill(0);
        textSize(48); 
        text(any_key, 600, 600); //Hope to create fading in out text
    }
    
    else{                           //gaming page
        background(#FFFFFF);
        image(upper_bar, 800, 400, 1600, 200); 
        image(check_point, 400, 400, 200, 200);
        image(lower_bar, 800, 700, 1600, 200);  
        image(check_point, 400, 700, 200, 200);
        image(score_icon, 200, 100);
    }
}

void draw_cursor(){
    PImage img;
    switch(curr_cursor){
        case 0:
            img = loadImage("pointer1.png");
            break;
            
        case 1:
            img = loadImage("pointer2.png");
            break; 
            
        case 2:
            img = loadImage("pointer3.png");
            break;
        
        case 3:
            img = loadImage("pointer4.png");
            break; 
            
        default:
            img = loadImage("pointer1.png");
            break;
    }
    image(img, 400, 400, 200, 200);  
  
  
    for(int i=0;i<queue.size();i++){
        queue.get(i).draw();
    }
}

void move_cursor(){
    for(int i=0;i<queue.size();i++){          //move all cursor
        queue.get(i).move();
    }
    while(queue.size() > 0){                 //remove cursors 
        if(queue.element().type == 0 && queue.element().x <= 400){
            if(queue.element().ans != curr_cursor){
                evaluation = new Evaluate(1);
                println("bad");
            }
            else{
                evaluation = new Evaluate(3);
                println("excellent");
            }
            queue.remove();        
        }
        
        else if(queue.element().type == 1 && queue.element().x <= 100){
            queue.remove();
            evaluation = new Evaluate(1);
            println("bad");
        
        }
        else{
            break;
        }
    }
}

void show_score(){
    
}

void chk_res(int res){
    if(queue.size()>0){  //not sensitive at all!
        if(queue.element().x < 550 && queue.element().x > 250 && res == queue.element().ans){
            println("excellent");
            queue.remove();
            evaluation = new Evaluate(3);
        }
        
        else if(queue.element().x < 700 && queue.element().x > 100 && res == queue.element().ans){
            println("normal");
            queue.remove();
            evaluation = new Evaluate(2);
        }
    } 
}

void chk_map(){
     if(index < 20){
         if(map[index].time - (millis() - prev) < 1000){
             queue.add(map[index++]);
         }
     }
}

void stop(){
    //port.stop();
    //minim.stop();
    //player.close();
}

void setup(){
    //port_init();
    img_init();
    
    //minim = new Minim(this);
    //player = minim.loadFile("", 2048);
    //player.play(); //play main page music
    
    size(1600, 900);
    frameRate(40);  //My laptop's limitation
 
    for(int i=0;i<20;i++){
        map[i] = new Cursor(int(random(0,2)), i*500 + 1100);
    }
    
    evaluation = new Evaluate(4);   //fake obj
}

void draw(){    //main function of this program 
    draw_background();
    if(!is_standby){    //gaming mode
        chk_map();
        move_cursor();
        draw_cursor();
        evaluation.draw();
    } 
}

void keyPressed(){
    switch(keyCode){
        case LEFT:
            break;
            
        case RIGHT:
            break;
            
        case DOWN: 
            break;
            
        case UP:
            break;   
    }
}


void keyReleased() {
    switch(keyCode){
        case UP:
            chk_res(0);
            break; 
            
        case LEFT:
            chk_res(1);
            break;   
            
        case DOWN:
            chk_res(2);
            break;   
            
        case RIGHT:
            chk_res(3);
            break;       
    }
    
    switch(key){
        case 'q':
            is_standby = true;
            break;
            
        case ' ':
            if(is_standby){
                is_standby = false;
                prev = millis();
            }
            else{
                chk_res(4);
            }
            break;
            
        case '8':
            curr_cursor = 0;
            break;
            
        case '4':
            curr_cursor = 1;
            break;
            
        case '2':
            curr_cursor = 2;
            break;
            
        case '6':
            curr_cursor = 3;
            break;
    }
}
