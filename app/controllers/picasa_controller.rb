class PicasaController < ApplicationController
  require 'zip/zip'

  def install
    #also used to reset the cookies
    cookies.permanent["last_post_date_#{current_subdomain}"] = nil

    @filename = "#{request.host}_picasa_upload.pbz"
    @uuid = UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, request.host_with_port)

    template = ERB.new IO.read(Rails.root.join('app','views','picasa','button.xml.erb'))
    @pbf = template.result(binding)
  end

  def button
    filename = "#{request.host}_picasa_upload.pbz"
    @uuid = UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, request.host_with_port)
    template = ERB.new IO.read(Rails.root.join('app','views','picasa','button.xml.erb'))

    t = Tempfile.new("#{@uuid}-#{Time.now}")
    Zip::ZipOutputStream.open(t.path) do |z|
      z.put_next_entry("{#{@uuid}}.pbf")
      z.write template.result(binding)
      z.put_next_entry("{#{@uuid}}.psd")
      z.write IO.read(Rails.root.join('app','views','picasa','button.psd'))
    end
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => filename
    t.close
  end

  def upload
    if not params['rss']
      params[:notice] = 'No Rss Provided'
      redirect_to root_path
    else
      rss_hash = Hash.from_xml(params['rss'].tempfile)
      @items = rss_hash['rss']['channel']['item']
      if not @items.is_a? Array
        @items = [@items]
      end
    end
  end

  def create
    params[:notice] ||= ""
    params.each do |name, uploaded_file|
      if uploaded_file.is_a? ActionDispatch::Http::UploadedFile
        post = Post.new(:image => uploaded_file, :site_name => current_subdomain)
        if post.save
          params[:notice] += "#{uploaded_file.original_filename} uploaded.\n "
        else
          params[:notice] += "#{uploaded_file.original_filename} FAILED.\n "
        end
      end
    end
    render :nothing => true
  end
end
