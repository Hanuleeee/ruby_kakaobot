## 카카오톡 플러스 친구

> https://github.com/5chang2/kakao_bot_sample

* 지금까지 만들었던 레일즈 서버는 유저가 URL을 통해서 요청을 하면 html 문서를 응답해 주었다. html과 css는 사용자가 보기편하기 위해서 사용한다. 하지만 서버가 서버에게 요청을 보낼때는 데이터만 전송해주는 것이 효율적이다.  JSON을 사용해서 데이터를 전송하는 방법을 알아보자.
* html문서를 응답하는 Rails를 JSON으로 응답시켜주기 위해서 `render json`을 추가한다. 

```ruby
  def keyboard
    @keyboard = {
        :type => "buttons",
        :buttons => ["로또", "메뉴", "고양이"]
    }
    render json: @keyboard  # json으로 랜더링시킴
  end
```



> scaffold 는 두가지 방법으로 랜더링이 될 수 있음 (`respond_to -` 부분)
>
> Why? html요청이 들어올수도 있고 , json 요청이 들어올수도 있어서



### 카카오톡 플러스친구 API

> [카카오톡 플러스친구 API](https://github.com/plusfriend/auto_reply)    "5.1. Home Keyboard API"

- **Method** : GET
- **URL** : http(s)://:your_server_url/keyboard
- **Content-Type** : application/json; charset=utf-8

-> 우리서버로 요청이 들어오는 부분



* 컨트롤러 생성

```
hanullllje:~/workspace $ rails g controller kakao keyboard
```

*routes.rb*

```ruby
Rails.application.routes.draw do
  get '/keyboard' => 'kakao#keyboard'   #수정하기(위에 URL조건 충족)
end
```



> 루비에서 Hash쓰는 방법 3가지
>
> 1.  "key" => "value",
> 2.  :key => "value",  
> 3.  key: "value"



'*app/controllers/kakao_controller.rb*'

: 버튼형식(선택)

```ruby
class KakaoController < ApplicationController
  def keyboard
    @keyboard = {
        :type => "buttons",
        :buttons => ["선택 1", "선택 2", "선택 3"]
    }
    render json: @keyboard
  end
end
```

-> 서버 시작을 한다.



*카카오톡 플러스친구 관리자센터 -> 스마트채팅 -> API형*

![](C:\Users\Hanul Lee\Desktop\api형.PNG)

* *관리 -> 상세설정 -> 공개설정 활성화*
* 카카오톡에서 플러스친구 이름/아이디로 검색해서 친구 추가를 한다.
* 위에서 만든 버튼을 확인할 수 있다. 하지만 아직 아무런 기능이 없으므로 버튼에 대한 기능을 추가해본다. 



####  간단한 기능 추가

`/message` 요청은 사용자가 선택한 명령어를 파트너사 서버로 전달하는 API 

- **Method** : POST
- **URL** : http(s)://:your_server_url/message
- **Content-Type** : application/json; charset=utf-8



'*routes.rb*'

```ruby
...
   post '/message' => 'kakao#message'   #추가
...
```



POST- http(s)://:your_server_url/message 

```
-result(hash)
	-messege(json)
		-text :string
		-photo(json)
		-message_button(json)
	-keyboard(json)
		-type : string (text, buttons)
		-butttons : Array ["로또", "메뉴"]
		
```

'*app/controllers/kakao_controller.rb*'

```ruby
class KakaoController < ApplicationController
  def keyboard
    @keyboard = {
        :type => "buttons",
        :buttons => ["로또", "메뉴", "고양이"]
    }
    render json: @keyboard
  end
  
  def message
    @user_msg = params[:content]  #사용자가 보낸 내용은 content에 담아서 전송됨
    
    @text = "기본 테스트"
    if @user_msg == "로또"
      @text = "행운의 번호는 : " + (1..45).to_a.sample(6).sort.to_s
    elsif @user_msg == "메뉴"
      @text = ["20층","시골집","서브웨이"].sample
    elsif @user_msg == "고양이"
      @url = "http://thecatapi.com/api/images/get?format=xml&type=jpg"
      @cat_xml = RestClient.get(@url)
      @cat_doc = Nokogiri::XML(@cat_xml)   #Search html/xml document
      @cat_url = @cat_doc.xpath("//url").text
      #@text = @cat_url
    end
    
    @return_msg = {
      :text => @text  
    }
    
    @return_msg_photo = {
      :text => "냥이 냥이 :D ",
      :photo => {
        :url => @cat_url,
        :width => 720,
        :height => 630
      }
      
    }
    
    @return_keyboard = {
        :type => "buttons",
        :buttons => ["로또", "메뉴", "고양이"]
    }
    
    # 응답
    if @user_msg == "고양이"
      @result = {
         :message => @return_msg_photo,
         :keyboard => @return_keyboard
    }
    else
      @result = {
         :message => @return_msg,
         :keyboard => @return_keyboard
    }
    end
    render json: @result
  end
end
```



> 레일즈 서버를 만들때 왜 token을 넣을까?
>
> -> api는 외부에서 우리에게 서버를 요청함 CSRF공격을 방어할필요가 없다.

'*app/controller/application_controller.rb*'

```ruby
...
    # protect_from_forgery with: :exception    #주석처리
...
```



#### cat api활용

> http://thecatapi.com/docs.html

`http://thecatapi.com/api/images/get?format=xml&type=jpg`

```
?
format=xml
&
type=jpg
```



#### Nokogiri 

> http://www.nokogiri.org/tutorials/parsing_an_html_xml_document.html
>
> Parsing an HTML/XML document
>
> Searching a XML/HTML Document



###  HEROKU Deploy

> https://dashboard.heroku.com

'*Gemfile*'

```ruby
...
gem 'sqlite3', :group => :development   		 # 수정
gem 'pg', :group => :production					# 추가
gem 'rails_12factor', :group => :production		 # 추가
...
```

'*config/database.yml*'

```ruby
# 변경전
# production:
#   <<: *default
#   database: db/production.sqlite3

# 변경후  
production:
  <<: *default
  adapter: postgresql      # 수정
  encoding: unicode		  # 수정
```



```bash
# git을 생성해서 파일을 올려준다.
git init
git add .
git commit -m "kakao_bot"

# 헤로쿠에 로그인해서 앱을 만들어준다
heroku login
heroku create

# 우리의 프로젝트를 헤로쿠에 디플로이 한다.
git push heroku master
```



카카오톡 플러스친구 관리자센터 -> 스마트채팅 -> API형 `앱 URL`수정 

```
https://my-kakao-bot.herokuapp.com/keyboard
```

: heroku를 써서 위와같이 URL을 바꾸면 서버가 꺼지지않고 계속 사용가능하다.