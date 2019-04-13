
import processing.serial.*;
import gifAnimation.*;
import ddf.minim.*;
import java.util.LinkedList;

class Cursor{
    public PImage img;
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
            //ans = int(random(4));
            ans = 0;
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
    public int counter;
    public int eval;
    
    Evaluate(int e){
        eval = e;
        counter = 20;
        if(e == 2){
            if(is_bonus)
                score += 20;
            else
                score += 10;
        }
        else if(e == 3){
            if(is_bonus)
                score += 40;
            else
                score += 20;
        }
    }
    
    void draw(){
        if(counter > 0){
            /*PImage eval_img;
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
            }*/
            textSize(32);
            fill(#FF00FF);
            switch(eval){
            case 1:               
                text("BAD", 1400, 100);
                break;
                
            case 2:
                text("NORMAL", 1400, 100);
                break;
                
            case 3:
                text("EXCELLENT", 1400, 100);
                break;
                
            default:
                break;
            }
            counter--;
        }
    }   
}

boolean is_standby = true;
boolean is_bonus = true;

PImage backimage, logo, upper_bar, lower_bar, score_img, check_point, bonus;

int index = 0;
int prev = 0;

int curr_cursor = 0;

int score = 0;
int combo;

int map_size = 0;

int frame = 0;
int fps_time = 0;
int frame_1_sec = 0;

Evaluate evaluation;
BufferedReader reader;
Cursor[] map = new Cursor[20];  //change to beatmap file in the future
LinkedList<Cursor> up_queue = new LinkedList<Cursor>();
LinkedList<Cursor> down_queue = new LinkedList<Cursor>();

Serial port;
Minim minim;  //music obj
AudioPlayer player = null; //music player obj
AudioPlayer up_sound = null;
AudioPlayer down_sound = null;

void img_init(){
    try{
        imageMode(CENTER);
        backimage = loadImage("background.png"); //Make a beautiful background-image
        logo = loadImage("logo.png");  //Make a beautiful logo image  
        upper_bar = loadImage("upper_bar.png");
        lower_bar = loadImage("lower_bar.png");
        score_img = loadImage("score_img.png");
        check_point = loadImage("check_point.png");
        bonus = loadImage("bonus.png");
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

void bgm_init(){
    minim = new Minim(this);
    String line;
    player = minim.loadFile("g_major_cut.mp3", 2048); //(filename, buffersize);
    up_sound = minim.loadFile("up_sound.wav");
    down_sound = minim.loadFile("down_sound.wav");
    reader = createReader("g_major.csv");
    while(true){
        try{
            line = reader.readLine();          
        }
        catch(IOException e){
            e.printStackTrace();
            line = null;
        }
        if(line == null){
            break;
        }
        String[] data = split(line, ',');       
        map[int(data[0])] = new Cursor(int(data[1]), int(data[2]));
        map_size++;
    }
}

void draw_background(){
    if(is_standby){  //standby page         
        background(backimage);                   
        image(logo, 800, 450);        
        String any_key = "Please key space to start";
        fill(0);
        textSize(32);
        textAlign(CENTER);
        text(any_key, 800, 600); //Hope to create fading in out text
    }
    
    else{      //gaming page
        if(is_bonus){            
            background(#FFFFFF);
            image(bonus, 800, 100);
        }
        else{
            background(#FFFFFF);
        }            
        //image(upper_bar, 800, 400, 1600, 200); 
        //image(lower_bar, 800, 700, 1600, 200);  
        //image(check_point, 400, 700, 200, 200);
        //image(score_img, 150, 75, 300, 150);            
    }
    //draw_fps();
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
    
    for(int i=0;i<up_queue.size();i++){
        up_queue.get(i).draw();
    }
    
    for(int i=0;i<down_queue.size();i++){
        down_queue.get(i).draw();
    }
}

void move_cursor(){                        //move all cursor
    for(int i=0;i<up_queue.size();i++){         
        up_queue.get(i).move();
    }
    
    for(int i=0;i<down_queue.size();i++){        
        down_queue.get(i).move();
    }
    
    if(up_queue.size() > 0){
        if(up_queue.element().x <= 400){
            if(up_queue.element().ans != curr_cursor){  //remove up cursors
                evaluation = new Evaluate(1);
                //println("bad");
                combo = 0;
            }
            else{
                evaluation = new Evaluate(3);
                //println("excellent");
                up_sound.rewind();
                up_sound.play();               
                combo++;
            }
            up_queue.remove();
        }
    }
    
    if(down_queue.size() > 0){                 //remove down cursors         
        if(down_queue.element().x <= 100){
            down_queue.remove();
            evaluation = new Evaluate(1);
            //println("bad");  
            combo = 0;
        }
    }
}

void draw_score(){
    //println(score);
    fill(0, 102, 153);
    text(score, 400, 75);
    if(combo > 0)
      text(combo + " combo", 400, 175);
}

void chk_down_res(int res){
    if(down_queue.size()>0){  //not sensitive at all!
        if(down_queue.element().x < 550 && down_queue.element().x > 250){
            if(down_queue.element().ans == res){
                //println("excellent");
                down_queue.remove();
                evaluation = new Evaluate(3);
                combo++;
            }
            else{
                //println("bad");
                down_queue.remove();
                evaluation = new Evaluate(1);
                combo = 0;
            }       
        }         
        else if(down_queue.element().x < 700 && down_queue.element().x > 100){
            if(down_queue.element().ans == res){
                //println("normal");
                down_queue.remove();
                evaluation = new Evaluate(2);
                combo++;
            }
            else{
                //println("bad");
                down_queue.remove();
                evaluation = new Evaluate(1);
                combo = 0;
            }
        }        
    } 
}

void update_queue(){
    if(index < map_size){
        if(map[index].time - (millis() - prev) <= 1000){   //From side to check point taking one second
            if(map[index].type == 0)
            up_queue.add(map[index++]);
            else if(map[index].type == 1){
            down_queue.add(map[index++]);
            }
        }
    }                  
}

void stop(){
    //port.stop();
    //minim.stop();
    //player.close();
} 

void read_port(){
    if(port.available() > 0){
        int val = port.read();
        switch(val){
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
}

void setup(){
    //port_init();
    img_init();
    bgm_init();
    //play main page music
    
    size(1600, 900);
    frameRate(30);  //Actually in game it would only 10~20 fps
 
    /*for(int i=0;i<20;i++){              //testing beatmap
        map[i] = new Cursor(int(random(0,2)), i*500 + 1100);
    }*/
    
    evaluation = new Evaluate(4);   //initalize score obj
}

void draw_true_fps(){
     frame++;
    if(millis() - fps_time >= 1000){
        fps_time = millis();
        frame_1_sec = frame;       
        frame = 0;
    }
    println(frame_1_sec);

}

void draw_fps(){
    /*frame++;
    if(millis() - fps_time >= 1000){
        fps_time = millis();
        frame_1_sec = frame;       
        frame = 0;
    }*/
    fill(#FF0000);
    textSize(32);
    text("FPS: " + int(frameRate), 150, 850);
}

int frame_time = 0;

void draw(){  //main function of this program        
    draw_background();
    if(!is_standby){    //gaming mode
        background(#FFFFFF);
        move_cursor(); 
            //TODO: delay need to be solved
        image(check_point, 400, 700, 200, 200);
        draw_cursor();
        update_queue();        
        draw_true_fps();
        evaluation.draw();
        draw_score();
        player.play();
        draw_fps();   
        //read_port();   
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
            chk_down_res(0);
             down_sound.rewind();
             down_sound.play(); 
            break; 
            
        case LEFT:
            chk_down_res(1);
            down_sound.rewind();
            down_sound.play(); 
            break;   
            
        case DOWN:
            chk_down_res(2);
            down_sound.rewind();
            down_sound.play(); 
            break;   
            
        case RIGHT:
            chk_down_res(3);
            down_sound.rewind();
            down_sound.play(); 
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
                chk_down_res(4);
                down_sound.rewind();
                down_sound.play();               
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
