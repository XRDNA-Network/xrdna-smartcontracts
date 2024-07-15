import { ExperienceFactory, ExperienceRegistry } from "../../../src/experience";

export interface IExperienceStack {

    getExperienceFactory(): ExperienceFactory;
    getExperienceRegistry(): ExperienceRegistry;
}