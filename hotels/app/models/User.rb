class User
 
  attr_accessor :first_name, :last_name, :email, :password
  def initialize(fname, lname, eid, pswd)
    @first_name = fname  
    @last_name = lname
    @email = eid
    @password = pswd
  end

end
 
