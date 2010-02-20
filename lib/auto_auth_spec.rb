module AutoAuthSpec
  def self.included(spec) 
    spec.instance_eval do
      controller = self.described_type.to_s.split("::").collect{|t| t.gsub("Controller","").underscore}.join("/")
      ActionController::Routing::Routes.routes.select { |route| route.defaults[:controller] == controller }.each do |route|
        original_segs = route.segments.delete_if{|s| s.to_s.match(/\(/)}
        original_name = ActionController::Routing::Routes.named_routes.routes.index(route).to_s
        name = original_name.blank? ? original_segs.join : original_name
        verb = route.conditions[:method].to_s
        action = route.requirements[:action].to_s
        it "should authenticate on #{verb.upcase} to #{name.strip}" do
          segmants = original_segs.find_all{|s| s.to_s.match(/^:/)}.collect{|s| s.to_s.gsub(":","").to_sym}
          params_hash = Hash[*segmants.zip(segmants.collect{|s| s.to_s.sub(":","")}).flatten]
          send(verb, action, params_hash)
          response.should redirect_to(sign_in_path)
        end
      end
    end
  end
end
