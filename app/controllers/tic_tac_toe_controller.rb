class TicTacToeController < ApplicationController

  def checkToken(token, expected)
    return token && token == expected
  end

  def create
    if not checkToken(params['token'], 'YVyjszmysk7T8Cr299F5Tbb4') then
      return render json: { :text => 'Incorrect token' }, :status => 400
    end

    channel = params['channel_id']
    userName = params['user_name']
    text = params['text']
    opponent = /(@)(.*)/.match(text.strip)[2]

    response = { :response_type => 'in_channel', :text => 'New game for ' + userName + ' and ' + opponent, :attachments => [ :text => channel ] }
    render json: response
  end

  def get
    if not checkToken(params['token'], 'pqNgvumzhx5SO6VWqd8YeShN') then
      return render json: { :text => 'Incorrect token' }, :status => 400
    end
    channel = params['channel_id']
    userName = params['user_name']
    text = params['text']
    b = Board.new(:channel => channel)
    b.player1 = userName
    b.player2 = 'testRobot'
    b.state = '001012200'
    b.next = userName
    response = { :response_type => 'in_channel', :text => 'New game for ' + userName, :attachments => [ b ] }
    render json: response
  end
end
