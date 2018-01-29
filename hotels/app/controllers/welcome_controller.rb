
class WelcomeController < ApplicationController

  @@aws_id = 'AKIAICR2XKECEFYWYIXA'
  @@aws_key = 'rwaQ7M0xM2pR+sK8D5UKRP8JS3XCUYX+rfn2oRya'
  @@aws_region = 'us-east-2'
  @@email_id=''
  @@start_date_cur='0'
  @@end_date_cur='0'
  @@adminDetails =nil

  @@cat='non'

  @@hotels = nil


########################################################################################################################
########################################################################################################################

  def loginpost
    @email = params[:signin_email]
    @pswd = params[:signin_password]

   @returnpage = 'main'   
   @showLoginModal=false
   @loginErrorMsg= ''
   @mainHotelsErrorMsg= ''

   @cities = []

   req_payload = {:id => @email , :pswd => @pswd}
   payload = JSON.generate(req_payload)

   resp = get_info_from_lambda('loginUser', payload)

	if resp["status"] == 'fail'
		@loginErrorMsg= resp["info"]
		@showLoginModal=true
		@returnpage = 'index'
	else		
		@@email_id=@email
		resp1 = get_info_from_lambda('getAllHotels', JSON.generate({}))

		if resp1["status"] == 'fail'
			@mainHotelsErrorMsg= 'Unable to fetch Data'		
		else
			@@hotels = resp1["info"]
			@@hotels.each do |hotel|
				unless @cities.include?(hotel["hotel_location"]["city"])
				   @cities << hotel["hotel_location"]["city"]
				end
			end
			@hotelDetails=@@hotels
		end



		if resp["cat"] == 'user'
			@@cat='user'
		else
			@@cat='admin'
			@returnpage = 'admin'
		end
	end

    render @returnpage
  end # method def end

########################################################################################################################
########################################################################################################################

  def regpost
    @fname = params[:signup_fname]
    @lname = params[:signup_lname]
    @email = params[:signup_email]
    @pswd = params[:signup_password]

   @returnpage = 'index'
   @showRegModal=false
   @showLoginModal=false
   @regErrorMsg= ''

    req_payload = {:id => @email , :fname=>@fname , :lname => @lname , :pswd => @pswd}
    payload = JSON.generate(req_payload)

    resp = get_info_from_lambda('registerUser', payload)
    if resp["status"] == 'fail'
	@regErrorMsg= 'Email Already Registered'
	@showRegModal=true
    else
	@showLoginModal=true
    end

    render @returnpage
  end # method def end

########################################################################################################################
########################################################################################################################

  def main

  @returnPage='main'

	@cities = []
	if @@hotels == nil
		resp = get_info_from_lambda('getAllHotels', JSON.generate({}))

		if resp["status"] == 'fail'
			@mainHotelsErrorMsg= 'Unable to fetch Data'		
		else
			@@hotels = resp["info"]
		end
	end

	@@hotels.each do |hotel|
		unless @cities.include?(hotel["hotel_location"]["city"])
		   @cities << hotel["hotel_location"]["city"]
		end
	end

	@hotelDetails=@@hotels


	if @cat == 'non'
		@returnPage='index'		
	elsif @@cat == 'user'
		@returnPage='main'
	else
		@returnPage='admin'
	end  

    render @returnPage
  end

########################################################################################################################
########################################################################################################################

  def signout
    session[:current_user_id] = nil
    session.delete(:current_user_id)
    reset_session
    render 'index'
  end

########################################################################################################################
########################################################################################################################

 def searchpost

    @mainSearchError=''
    @city = ''
    @start_date = ''
    @end_date = ''

    @cities = []
    if @@hotels == nil
	resp1 = get_info_from_lambda('getAllHotels', JSON.generate({}))
	if resp1["status"] == 'fail'
		@mainHotelsErrorMsg= 'Unable to fetch Data'		
	else
		@@hotels = resp1["info"]
	end
    end
    @@hotels.each do |hotel|
	unless @cities.include?(hotel["hotel_location"]["city"])
	   @cities << hotel["hotel_location"]["city"]
	end
    end

    @hotelDetails=[]
    if params[:city].present? && params[:start_date].present? && params[:end_date].present?
      @city = params[:city]
      @start_date = params[:start_date]
      @end_date = params[:end_date]
 
      @@start_date_cur = @start_date
      @@end_date_cur = @end_date
	

      @@hotels.each do |hotel|
	if hotel["hotel_location"]["city"] == @city
		@hotelDetails << hotel
	end
      end
    else
      @mainSearchError ='Please Fill All Fields'
    end

#do work
   render 'main'


 end

########################################################################################################################
########################################################################################################################

 def booknow

   @hid = params[:hid]
   @rid = params[:rid]   
  
    req_payload = {:id => @@email_id , :rid=>@rid , :hid => @hid , :sdt => @@start_date_cur , :edt => @@end_date_cur }
    payload = JSON.generate(req_payload)

        resp = get_info_from_lambda('bookHotel', payload)
	if resp["status"] == 'fail'
		@mainHotelsErrorMsg= resp["info"]
	else
		@mainHotelsErrorMsg = 'Hotel Booked'
	end


   @cities = []
    if @@hotels == nil
	resp1 = get_info_from_lambda('getAllHotels', JSON.generate({}))
	if resp1["status"] == 'fail'
		@mainHotelsErrorMsg= 'Unable to fetch Data'		
	else
		@@hotels = resp1["info"]
	end
    end
    @@hotels.each do |hotel|
	unless @cities.include?(hotel["hotel_location"]["city"])
	   @cities << hotel["hotel_location"]["city"]
	end
    end

    @hotelDetails=@@hotels

   render 'main'

 end

########################################################################################################################
########################################################################################################################

 def admin
	@toReturn = 'main'
	if @@cat == 'user'
		@toReturn='main'
	else
		@toReturn='admin'
	end  

   render @toReturn
 end

########################################################################################################################
########################################################################################################################

 def viewAllHotels
	
	if @@hotels == nil
		resp1 = get_info_from_lambda('getAllHotels', JSON.generate({}))
		if resp1["status"] == 'fail'
			@mainHotelsErrorMsg= 'Unable to fetch Data'		
		else
			@@hotels = resp1["info"]
		end
	end

	@hotelDetails=@@hotels
	
	render 'admin'
 end

########################################################################################################################
########################################################################################################################

  def get_info_from_lambda(lambda, payload)
# aws call starts
    @resp_payload

    begin
      credentials = Aws::Credentials.new(@@aws_id, @@aws_key)
      client = Aws::Lambda::Client.new(region:@@aws_region, credentials: credentials)

      resp = client.invoke({
        function_name: lambda, # required
        log_type: "None", # accepts None, Tail
        payload: payload
      })
      @resp_payload = JSON.parse(resp.payload.string)  # , symbolize_names: true)
    rescue Aws::Lambda::Errors::ServiceError
      @resp_payload = JSON.parse("{}")
    end #Lambda Call End     

  return @resp_payload

  end

########################################################################################################################
########################################################################################################################

end #class end
