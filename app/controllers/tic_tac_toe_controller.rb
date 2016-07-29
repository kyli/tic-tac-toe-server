class TicTacToeController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def checkToken(token, expected)
    return token && token == expected
  end

  def create
    if not checkToken(params['token'], 'YVyjszmysk7T8Cr299F5Tbb4') then
      return render json: { :text => 'Incorrect token' }, :status => 400
    end

    channel = params['channel_id']
    existing = Board.find_by(:channel => channel)
    if existing && existing.next then
      return render json: { :text => 'There is one game per channel at a time' }
    end

    if existing then
      existing.destroy
    end

    userName = params['user_name']
    text = params['text']

    if !userName || !text then
      return render json: { :text => 'Bad command. /newgame @username' }
    end

    opponent = /(@)(.*)/.match(text.strip)[2]
    newgame = Board.new(:channel => channel, :player1 => userName, :player2 => opponent, :state => '000000000', :next => userName)
    if newgame.save() then
      response = { :response_type => 'in_channel', :text => 'New game created for ' + userName + ' and ' + opponent + '. @' + userName + '\'s move'}
      render json: response
    else
      render json: { :text => 'Something happened, try again' }
    end
  end

  def del
    if not checkToken(params['token'], 'eaGsF48NxM8J9bqDyRew1vHD') then
      return render json: { :text => 'Incorrect token' }, :status => 400
    end

    channel = params['channel_id']
    existing = Board.find_by(:channel => channel)
    if existing then
      existing.destroy
      return render json: { :text => 'Removed the current game for the channel. It was between ' + existing.player1 + " and " + existing.player2 }
    end
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
