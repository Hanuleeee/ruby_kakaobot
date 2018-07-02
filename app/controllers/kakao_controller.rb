class KakaoController < ApplicationController
  def keyboard
    @keyboard = {
        :type => "buttons",
        :buttons => ["로또", "메뉴", "고양이"]
    }
    render json: @keyboard
  end
  
  def message
    @user_msg = params[:content]
    @text = "기본 테스트"
    if @user_msg == "로또"
      @text = "행운의 번호는 : " + (1..45).to_a.sample(6).sort.to_s
    elsif @user_msg == "메뉴"
      @text = ["20층","시골집","서브웨이"].sample
    elsif @user_msg == "고양이"
      @url = "http://thecatapi.com/api/images/get?format=xml&type=jpg"
      @cat_xml = RestClient.get(@url)
      @cat_doc = Nokogiri::XML(@cat_xml)
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

    #  루비에서 Hash쓰는 방법 3가지
    #  "key" => "value",
    #  :key => "value",
    #  key: "value"