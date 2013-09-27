module CanvasOauth
  module CanvasCache
    def redis_key(entity, *ids)
      "#{entity}:#{ids.join(':')}"
    end

    def cached_response(key, request)
      if json = redis.get(key)
        JSON.parse(json)
      else
        request.call
      end
    end

    def cached_user_enrollments(user_id)
      cached_response redis_key(:user_enrollment, user_id), lambda { canvas.get_user_enrollments(user_id) }
    end

    def cached_section(section_id)
      cached_response redis_key(:section, section_id), lambda { canvas.get_section(section_id) }
    end

    def cached_sections(course_id)
      cached_response redis_key(:sections, course_id), lambda { canvas.get_sections(course_id) }
    end

    def cached_course(course_id)
      cached_response redis_key(:course, course_id), lambda { canvas.get_course(course_id) }
    end

    def cached_account(account_id)
      cached_response redis_key(:account, account_id), lambda { canvas.get_account(account_id) }
    end

    def refresh_course!(course_id)
      cache_response redis_key(:course, course_id), canvas.get_course(course_id)
      cache_response redis_key(:sections, course_id), canvas.get_sections(course_id)
      cached_sections(course_id).each do |section|
        key = redis_key(:section, section['id'])
        # we may not have permission to load every section in the course, so
        # just delete them here, and they'll get refreshed lazily as needed
        redis.del key
      end
    end

    def cache_response(key, response)
      if response
        json = response.to_json
        redis.setex key, 12.hours.to_i, json
      end

      return json
    end

    def redis
      $REDIS
    end
  end
end
