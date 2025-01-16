// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import CharacterCounter from '@stimulus-components/character-counter'

eagerLoadControllersFrom("controllers", application)
application.register("character-counter", CharacterCounter)