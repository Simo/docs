---
layout: default 
permalink: /angular/test
---

h1. Angular testing

L'obiettivo è quello di mostrare le principali tecniche per testare un applicazione Angular in ogni suo componente: Component, Service, Http, Pipe, Directive, Router e Observable

L'area del test è stata potenziata dall'introduzione degli NgModule. in questa guida utilizzeremo Jasmine come framework di test, ma è possibile anche utilizzare Mocha.

h2. Jasmine

Jasmine è un framework di test open-source sviluppato da Pivotal Labs che usa una sintassi behavior-driven che produce test chiari e comprensibili.

h3. Concetti cardine

* *Suites* - _*describe(string, function)*_ sono contenitori logici di specs (metodi di test)
* *Specs* - _*it(string, function)*_ sono metodi di test che contengono una (o più) expectations
* *Expectations* - _*expect(actual).toBe(expected)*_ sono asserzioni che valutate a _true_ o _false_
* *Matchers* - sono degli helpers per asserzioni. (es: _*toBe(expected)*_, _*toEqual(expected)*_). La lista completa è https://github.com/JamieMason/Jasmine-Matchers

h3. Handlers

Jasmine mette a disposizione quattro metodi per gestire il ciclo di vita dei test ed evitare la duplicazione di codice all'interno delle specs

* _*beforeEach*_
* _*beforeAll*_
* _*afterEach*_
* _*afterAll*_

h2. Angular

Jasmine può essere utilizzato come _standalone_ (importando le dipendenze e utilizzando lo SpecRunner.html fornito dal framework) oppure integrato in un test runner come _*Karma*_ (già configurato in ogni applicazione creata con ng-cli)

h3. Dependency Injection

Il corrispettivo di NgModule in ambiente di test è _*TestBed*_. Quello che si fa è chiamare

{% highlight typescript %}
TestBed.configureTestingModule()
{% endhighlight %}

al quale si passa una configurazione che permetterà di configurare tutte le dipendenze necessarie.

Esempio:

{% highlight typescript linenos %}
@NgModule({
  declarations: [ ComponentToTest ] 
  providers: [ MyService ]
}) 

class AppModule { }
TestBed.configureTestingModule({
  declarations: [ ComponentToTest ],
  providers: [ MyService ]  
});

//ci facciamo passare l'istanza direttamente da TestBed
let service = TestBed.get(MyService);
{% endhighlight %}

il metodo *inject* ci permette di recuperare le dipendenze a livello di TestBed

{% highlight typescript %}
it('should return ...', inject([MyService], service => { 
  service.foo();
}));
{% endhighlight %}

il metodo *injector* del Component invece permette di recuperare una dipendenza a livello del Component stesso

{% highlight typescript %}
@Component({ 
  providers: [ MyService ] 
}) 
class ComponentToTest { }

let fixture = TestBed.createComponent(ComponentToTest);
let service = fixture.debugElement.injector.get(MyService);
{% endhighlight %}

Vediamo come applicare questa tecnica:

{% highlight typescript %}
describe('Service: LanguagesService', () => {
  beforeEach(() => TestBed.configureTestingModule({
    providers: [ LanguagesService ]
  }));
  
  it('should return available languages', inject([LanguagesService], service => {
    expect(service.get()).toContain('it');
  }));
})
{% endhighlight %}

E' possibile spingersi oltre per ridurre ancora la duplicazione del codice scrivendo

{% highlight typescript %}
describe('Service: LanguagesService', () => {
  let service;

  beforeEach(() => TestBed.configureTestingModule({
    providers: [ LanguagesService ]
  }));

  beforeEach(inject([LanguagesService], s => {
    service = s;
  }));

  it('should return available languages', () => {
    expect(service.get()).toContain('it');
  });
});
{% endhighlight %}

h3. Istanziazione di un Component

Quando Angular istanzia un Component esegue prima l'istanziazione della classe, poi attraverso una chiamata asincrona carica i relativi file di template e stile (_.html_ e _.css_)

Quindi per testare l'effettiva istanziazione di un componente

{% highlight typescript %}
// istanziazione sincrona
  beforeEach(() => {
    fixture = TestBed.createComponent(MyTestComponent);
  });
{% endhighlight %}

invece con una chiamata asincrona, come se dovesse richiamare template e css esterni

{% highlight typescript %}
// istanziazione asincrona 
  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ MyTestComponent ],
    }).compileComponents(); // a questo punto carica templates and css
  }));
{% endhighlight %}

_*async*_ è l'automatismo messo a disposizione del framework di test di Angular per contenere le chiamate asincrone.